module PriorAuthority
  module CheckAnswers
    class Report
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::UrlHelper

      GROUPS = %w[
        application_detail
        contact_details
        about_case
        about_request
        further_information
      ].freeze

      attr_reader :application

      def initialize(application)
        @application = application
      end

      def section_groups
        GROUPS.map do |group_name|
          section_group(group_name, public_send(:"#{group_name}_section"))
        end
      end

      def section_group(name, section_list)
        {
          heading: group_heading(name),
          sections: sections(section_list)
        }
      end

      def sections(section_list)
        section_list.map do |data|
          {
            card: {
              title: data.title,
              actions: actions(data.section, request_method: data.request_method)
            },
            rows: data.rows
          }
        end
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
          CaseDetailCard.new(application),
          HearingDetailCard.new(application),
        ]
      end

      def about_request_section
        [
          PrimaryQuoteCard.new(application),
          # TODO: AlternativeQuotesCard.new(application),
          ReasonWhyCard.new(application),
        ]
      end

      def further_information_section
        [
          # TODO: FurtherInformationCard.new(application)
        ]
      end

      private

      def actions(key, request_method: :edit)
        helper = Rails.application.routes.url_helpers

        [
          govuk_link_to(
            'Change',
            helper.url_for(controller: "prior_authority/steps/#{key}",
                           action: request_method,
                           application_id: application.id,
                           only_path: true)
          ),
        ]
      end

      def group_heading(group_key, **)
        I18n.t("prior_authority.steps.check_answers.groups.#{group_key}.heading", **)
      end
    end
  end
end
