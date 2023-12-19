module Assess
  module V1
    class EqualityDetails < Assess::BaseViewModel
      attribute :answer_equality, :translated
      attribute :ethnic_group, :translated
      attribute :gender, :translated
      attribute :disability, :translated

      def key
        'equality_details'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      # rubocop:disable Metrics/MethodLength
      def data
        [
          {
            title: I18n.t("assess.claim_details.#{key}.questions"),
            value: answer_equality
          },
          {
            title: I18n.t("assess.claim_details.#{key}.ethnic_group"),
            value: ethnic_group
          },
          {
            title: I18n.t("assess.claim_details.#{key}.identification"),
            value: gender
          },
          {
            title: I18n.t("assess.claim_details.#{key}.disability"),
            value: disability
          },
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def rows
        { title:, data: }
      end
    end
  end
end
