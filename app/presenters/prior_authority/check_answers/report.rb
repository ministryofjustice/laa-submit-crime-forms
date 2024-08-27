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
          rfi_cards,
        ].flatten.compact
      end

      private

      def rfi_cards
        if @verbose
          (compact_further_information_cards + incorrect_information_cards).sort_by { _1[:date] }
                                                                           .reverse
                                                                           .pluck(:card)
        elsif application.further_information_needed?
          FurtherInformationCard.new(application)
        end
      end

      def group_heading(group_key, **)
        I18n.t("prior_authority.steps.check_answers.groups.#{group_key}.heading", **)
      end

      def compact_further_information_cards
        application.further_informations
                   .order(requested_at: :desc)
                   .map do |further_information|
          {
            date: further_information.requested_at,
            card: CompactFurtherInformationCard.new(further_information, skip_links:),
          }
        end
      end

      def incorrect_information_cards
        application.incorrect_informations
                   .order(requested_at: :desc)
                   .map do |incorrect_information|
          {
            date: incorrect_information.requested_at,
            card: IncorrectInformationCard.new(incorrect_information),
          }
        end
      end
    end
  end
end
