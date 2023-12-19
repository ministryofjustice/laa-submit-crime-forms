module Assess
  module V1
    class ClaimJustification < Assess::BaseViewModel
      attribute :reasons_for_claim

      def key
        'claim_justification'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      def reasons_for_claim_list
        reasons = reasons_for_claim&.map { |row| row[I18n.locale.to_s] || row['value'] } || []
        ApplicationController.helpers.sanitize(reasons.join('<br>'), tags: %w[br])
      end

      def data
        [
          {
            title: I18n.t("assess.claim_details.#{key}.reasons_for_claim"),
            value: reasons_for_claim_list
          }
        ]
      end

      def rows
        { title:, data: }
      end
    end
  end
end
