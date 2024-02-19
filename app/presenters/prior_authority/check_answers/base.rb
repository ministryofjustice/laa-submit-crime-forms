# OPTMIZE: share with nsm via concern or inheritance?
module PriorAuthority
  module CheckAnswers
    class Base
      include LaaMultiStepForms::CheckMissingHelper
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::TagHelper

      attr_accessor :group, :section

      delegate :sanitize, to: 'ApplicationController.helpers'

      def translate_table_key(section, key, **)
        I18n.t("prior_authority.steps.check_answers.edit.sections.#{section}.#{key}", **)
      end

      def title(**)
        I18n.t("prior_authority.steps.check_answers.groups.#{group}.#{section}.title", **)
      end

      def rows
        row_data.map do |row|
          row_content(row[:head_key], row[:text], row[:actions], row[:head_opts] || {})
        end
      end

      def request_method
        :edit
      end

      # :nocov:
      def row_data
        raise 'Implement in subclass'
      end
      # :nocov:

      def row_content(head_key, text, actions = [], head_opts = {})
        heading = translate_table_key(section, head_key, **head_opts)

        {
          key: {
            text: heading,
            classes: 'govuk-summary-list__value-width-50'
          },
          value: {
            text:
          },
          actions: actions
        }
      end

      def actions
        helper = Rails.application.routes.url_helpers

        [
          govuk_link_to(
            I18n.t('generic.change'),
            helper.url_for(controller: "prior_authority/steps/#{section}",
                           action: request_method,
                           application_id: application.id,
                           only_path: true)
          ),
        ]
      end
    end
  end
end
