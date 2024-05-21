module Nsm
  module CostSummary
    class Disbursements < Base
      TRANSLATION_KEY = self
      attr_reader :disbursements, :claim

      def initialize(disbursements, claim)
        @claim = claim
        @disbursements = disbursements
      end

      def rows
        disbursements.map do |disbursement|
          [
            { text: translated_text(disbursement), classes: 'govuk-table__header' },
            { text: NumberTo.pounds(disbursement.total_cost_pre_vat), classes: 'govuk-table__cell--numeric' },
          ]
        end
      end

      def total_cost
        @total_cost ||= disbursements.filter_map(&:total_cost_pre_vat).sum
      end

      def title
        translate('disbursements')
      end

      def translated_text(disbursement)
        check_missing(disbursement.translated_disbursement_type)
      end
    end
  end
end
