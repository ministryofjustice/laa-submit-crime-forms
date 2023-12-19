module Assess
  module V1
    class ClaimDetails < Assess::BaseViewModel
      attribute :prosecution_evidence
      attribute :defence_statement
      attribute :number_of_witnesses
      attribute :supplemental_claim
      attribute :work_before
      attribute :work_after
      attribute :work_before_date
      attribute :work_after_date
      attribute :preparation_time
      attribute :time_spent

      def key
        'claim_details'
      end

      def title
        I18n.t("assess.claim_details.#{key}.title")
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
      def data
        [
          {
            title: I18n.t("assess.claim_details.#{key}.prosecution_evidence"),
            value:  prosecution_evidence
          },
          {
            title: I18n.t("assess.claim_details.#{key}.defence_statement"),
            value:  defence_statement
          },
          {
            title: I18n.t("assess.claim_details.#{key}.number_of_witnesses"),
            value:  number_of_witnesses
          },
          {
            title: I18n.t("assess.claim_details.#{key}.supplemental_claim"),
            value:  supplemental_claim&.capitalize
          },
          {
            title: I18n.t("assess.claim_details.#{key}.preparation_time"),
            value:  preparation_time&.capitalize
          },
          (unless preparation_time == 'no'
             {
               title: I18n.t("assess.claim_details.#{key}.preparation_time"),
               value: ApplicationController.helpers.format_period(time_spent)
             }
           end),
          {
            title: I18n.t("assess.claim_details.#{key}.work_before"),
            value:  work_before&.capitalize
          },
          (unless work_before == 'no'
             {
               title: I18n.t("assess.claim_details.#{key}.work_before_date"),
               value: ApplicationController.helpers.format_in_zone(work_before_date)
             }
           end),
          {
            title: I18n.t("assess.claim_details.#{key}.work_after"),
            value:  work_after&.capitalize
          },
          (unless work_after == 'no'
             {
               title: I18n.t("assess.claim_details.#{key}.work_after_date"),
               value: ApplicationController.helpers.format_in_zone(work_after_date)
             }
           end),
        ].compact
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity

      def rows
        { title:, data: }
      end
    end
  end
end
