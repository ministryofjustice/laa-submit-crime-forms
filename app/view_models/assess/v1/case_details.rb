module Assess
  module V1
    class CaseDetails < Assess::BaseViewModel
      attribute :main_offence
      attribute :main_offence_date
      attribute :assigned_counsel
      attribute :unassigned_counsel
      attribute :agent_instructed
      attribute :remitted_to_magistrate
      attribute :remitted_to_magistrate_date

      def key
        'case_details'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def data
        [
          {
            title: I18n.t("assess.claim_details.#{key}.main_offence"),
            value: main_offence
          },
          {
            title: I18n.t("assess.claim_details.#{key}.main_offence_date"),
            value: ApplicationController.helpers.format_in_zone(main_offence_date)
          },
          {
            title: I18n.t("assess.claim_details.#{key}.assigned_counsel"),
            value: assigned_counsel&.capitalize
          },
          {
            title: I18n.t("assess.claim_details.#{key}.unassigned_counsel"),
            value: unassigned_counsel&.capitalize
          },
          {
            title: I18n.t("assess.claim_details.#{key}.agent_instructed"),
            value: agent_instructed&.capitalize
          },
          {
            title: I18n.t("assess.claim_details.#{key}.remitted_to_magistrate"),
            value: remitted_to_magistrate&.capitalize
          },
          (unless remitted_to_magistrate == 'no'
             {
               title: I18n.t("assess.claim_details.#{key}.remitted_to_magistrate_date"),
               value: ApplicationController.helpers.format_in_zone(remitted_to_magistrate_date)
             }
           end)
        ].compact
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def rows
        { title:, data: }
      end
    end
  end
end
