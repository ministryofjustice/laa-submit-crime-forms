module Assess
  module V1
    class HearingDetails < Assess::BaseViewModel
      attribute :first_hearing_date
      attribute :number_of_hearing
      attribute :court
      attribute :in_area
      attribute :youth_court
      attribute :hearing_outcome, :translated
      attribute :matter_type, :translated

      def key
        'hearing_details'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def data
        [
          {
            title: I18n.t("assess.claim_details.#{key}.first_hearing_date"),
            value: ApplicationController.helpers.format_in_zone(first_hearing_date)
          },
          {
            title: I18n.t('assess.claim_details.hearing_details.number_of_hearing'),
            value: number_of_hearing
          },
          {
            title: I18n.t("assess.claim_details.#{key}.court"),
            value: court
          },
          {
            title: I18n.t("assess.claim_details.#{key}.in_area"),
            value: in_area&.capitalize
          },
          {
            title: I18n.t("assess.claim_details.#{key}.youth_court"),
            value: youth_court&.capitalize
          },
          {
            title: I18n.t("assess.claim_details.#{key}.hearing_outcome"),
            value: "#{hearing_outcome&.value} - #{hearing_outcome}"
          },
          {
            title: I18n.t("assess.claim_details.#{key}.matter_type"),
            value: "#{matter_type&.value} - #{matter_type}"
          }
        ]
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def rows
        { title:, data: }
      end
    end
  end
end
