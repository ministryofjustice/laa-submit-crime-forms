module Nsm
  module CostSummary
    class Disbursements < Base
      TRANSLATION_KEY = self
      attr_reader :disbursement_forms, :claim

      def initialize(disbursements, claim)
        @claim = claim
        @disbursement_forms = disbursements.map do |disbursement|
          Nsm::Steps::DisbursementCostForm.build(disbursement, application: claim)
        end
      end

      def rows
        disbursement_forms.map do |form|
          {
            key: { text: translated_text(form), classes: 'govuk-summary-list__value-width-50' },
            value: { text: NumberTo.pounds(form.total_cost_pre_vat) },
          }
        end
      end

      def footer_vat_row
        return [] if total_cost_inc_vat.zero?

        [
          {
            key: { text: translate('.footer.total_inc_any_vat'), classes: 'govuk-summary-list__value-width-50' },
            value: { text: NumberTo.pounds(total_cost_inc_vat), classes: 'govuk-summary-list__value-bold' },
          }
        ]
      end

      def total_cost
        @total_cost ||= disbursement_forms.filter_map(&:total_cost_pre_vat).sum
      end

      def total_cost_inc_vat
        @total_cost_inc_vat ||= disbursement_forms.filter_map(&:total_cost).sum
      end

      def title
        translate('disbursements', total: NumberTo.pounds(total_cost_inc_vat))
      end

      private

      # rubocop:disable Metrics/AbcSize
      def translated_text(form)
        if form.record.disbursement_type == DisbursementTypes::OTHER.to_s
          known_other = OtherDisbursementTypes.values.include?(OtherDisbursementTypes.new(form.record.other_type))
          return translate("other.#{form.record.other_type}") if known_other

          check_missing(form.record.other_type)
        else
          check_missing(form.record.disbursement_type.present?) do
            translate("standard.#{form.record.disbursement_type}")
          end
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
