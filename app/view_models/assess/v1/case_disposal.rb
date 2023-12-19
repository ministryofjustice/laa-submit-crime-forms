module Assess
  module V1
    class CaseDisposal < Assess::BaseViewModel
      attribute :plea, :translated
      attribute :plea_category

      def key
        'case_disposal'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      def data
        [
          {
            title: plea_category,
            value:  plea.to_s
          }
        ]
      end

      def rows
        { title:, data: }
      end
    end
  end
end
