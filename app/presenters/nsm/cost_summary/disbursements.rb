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
          [
            { text: translated_text(form), classes: 'govuk-table__header' },
            { text: NumberTo.pounds(form.total_cost_pre_vat), classes: 'govuk-table__cell--numeric' },
          ]
        end
      end

      def total_cost
        @total_cost ||= disbursement_forms.filter_map(&:total_cost_pre_vat).sum
      end

      def title
        translate('disbursements')
      end

      def translated_text(form)
        check_missing(form.record.translated_disbursement_type)
      end
    end
  end
end
