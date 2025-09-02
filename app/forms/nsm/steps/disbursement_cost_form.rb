module Nsm
  module Steps
    class DisbursementCostForm < ::Steps::AddAnotherForm
      include DisbursementCosts

      attr_writer :apply_vat

      attribute :miles, :fully_validatable_decimal, precision: 10, scale: 3
      attribute :total_cost_without_vat, :gbp
      attribute :details, :string
      attribute :prior_authority, :value_object, source: YesNoAnswer

      validates :miles, presence: true, is_a_number: true, numericality: { greater_than: 0 }, unless: :other_disbursement_type?
      validates :total_cost_without_vat, presence: true, numericality: { greater_than: 0 }, is_a_number: true,
                                         if: :other_disbursement_type?
      validates :details, presence: true
      validates :prior_authority, presence: true, inclusion: { in: YesNoAnswer.values }, if: :other_disbursement_type?

      def apply_vat
        @apply_vat.nil? ? record.apply_vat == 'true' : @apply_vat == 'true'
      end

      def calculation_rows
        [
          calculation_rows_header,
          calculation_rows_values
        ]
      end

      private

      def calculation_rows_header
        [translate(:net_cost_claimed), translate(:vat_on_claimed), translate(:total_claimed)]
      end

      def calculation_rows_values
        [
          {
            text: LaaCrimeFormsCommon::NumberTo.pounds(total_cost_pre_vat || 0),
            html_attributes: { id: 'net-cost-claimed' }
          },
          {
            text: LaaCrimeFormsCommon::NumberTo.pounds(vat || 0),
            html_attributes: { id: 'vat-on-claimed' }
          },
          {
            text: LaaCrimeFormsCommon::NumberTo.pounds(total_cost || 0),
            html_attributes: { id: 'total-claimed' },
          }
        ]
      end

      def translate(key)
        I18n.t("nsm.steps.disbursement_cost.edit.#{key}")
      end

      def persist!
        record.update!(attributes_with_resets)
      end

      def attributes_with_resets
        attributes.merge(
          'miles' => other_disbursement_type? ? nil : miles,
          'prior_authority' => other_disbursement_type? ? prior_authority : nil,
          'total_cost_without_vat' => other_disbursement_type? ? total_cost_without_vat : nil,
          'apply_vat' => apply_vat ? 'true' : 'false'
        )
      end
    end
  end
end
