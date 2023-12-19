module Assess
  module V1
    class DetailsOfClaim < Assess::BaseViewModel
      attribute :ufn
      attribute :claim_type, :translated
      attribute :rep_order_date

      def key
        'details_of_claim'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      # rubocop:disable Metrics/MethodLength
      def data
        [
          {
            title: I18n.t("assess.claim_details.#{key}.ufn"),
            value: ufn
          },
          {
            title: I18n.t("assess.claim_details.#{key}.claim_type"),
            value:  claim_type.to_s
          },
          {
            title: I18n.t("assess.claim_details.#{key}.rep_order_date"),
            value: ApplicationController.helpers.format_in_zone(rep_order_date)
          }
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def rows
        { title:, data: }
      end
    end
  end
end
