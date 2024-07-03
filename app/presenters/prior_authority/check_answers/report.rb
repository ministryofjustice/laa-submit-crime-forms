module PriorAuthority
  module CheckAnswers
    class Report
      GROUPS = %w[
        application_detail
        contact_details
        about_case
        about_request
      ].freeze

      attr_reader :application, :skip_links, :verbose

      def initialize(application, verbose: false, skip_links: false)
        @application = application
        @verbose = verbose
        @skip_links = skip_links
      end

      def section_groups
        GROUPS.map do |group_name|
          section_group(group_name, public_send(:"#{group_name}_section"))
        end
      end

      def section_group(name, section_list)
        {
          heading: group_heading(name),
          sections: section_list,
        }
      end

      def application_detail_section
        [UfnCard.new(application)]
      end

      def contact_details_section
        [CaseContactCard.new(application)]
      end

      def about_case_section
        [
          ClientDetailCard.new(application),
          *case_and_hearing_detail_cards,
        ]
      end

      def case_and_hearing_detail_cards
        if application.prison_law?
          [
            NextHearingCard.new(application)
          ]
        else
          [
            CaseDetailCard.new(application),
            HearingDetailCard.new(application),
          ]
        end
      end

      def about_request_section
        [
          PrimaryQuoteCard.new(application, verbose:, skip_links:),
          AlternativeQuotesCard.new(application, verbose:),
          ReasonWhyCard.new(application, skip_links:),
          further_information_cards,
        ].flatten.compact
      end

      private

      def further_information_cards
        return unless application.further_informations.any?

        if @verbose
          application.further_informations
                     .order(requested_at: :desc)
                     .map { CompactFurtherInformationCard.new(_1, skip_links:) }
        else
          FurtherInformationCard.new(application)
        end
      end

      def group_heading(group_key, **)
        I18n.t("prior_authority.steps.check_answers.groups.#{group_key}.heading", **)
      end
    end
  end
end
