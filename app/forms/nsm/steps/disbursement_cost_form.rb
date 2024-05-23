module Nsm
  module Steps
    class DisbursementCostForm < ::Steps::BaseFormObject
      include DisbursementCosts
      attr_writer :apply_vat

      attribute :miles, :decimal, precision: 10, scale: 3
      attribute :total_cost_without_vat, :decimal, precision: 10, scale: 2
      attribute :details, :string
      attribute :prior_authority, :value_object, source: YesNoAnswer

      validates :miles, presence: true, numericality: { greater_than: 1 }, unless: :other_disbursement_type?
      validates :total_cost_without_vat, presence: true, numericality: { greater_than: 1 },
if: :other_disbursement_type?
      validates :details, presence: true
      validates :prior_authority, presence: true, inclusion: { in: YesNoAnswer.values }, if: :auth_required?

      def apply_vat
        @apply_vat.nil? ? record.vat_amount.to_f.positive? : @apply_vat == 'true'
      end

      def calculation_rows
        [
          [translate(:before_vat), translate(:after_vat)],
          [{
            text: NumberTo.pounds(total_cost_pre_vat),
            html_attributes: { id: 'total-without-vat' }
          },
           {
             text: NumberTo.pounds(total_cost),
             html_attributes: { id: 'total-with-vat' },
           }],
        ]
      end

      private

      def translate(key)
        I18n.t("nsm.steps.disbursement_cost.edit.#{key}")
      end

      def persist!
        record.update!(attributes_with_resets)
      end

      def attributes_with_resets
        attributes.merge(
          'miles' => other_disbursement_type? ? nil : miles,
          'total_cost_without_vat' => total_cost_pre_vat,
          'vat_amount' => vat,
          'apply_vat' => apply_vat ? 'true' : 'false'
        )
      end
    end
  end
end
