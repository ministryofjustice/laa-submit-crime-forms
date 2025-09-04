# OPTMIZE: share with nsm via concern or inheritance?
module PriorAuthority
  module CheckAnswers
    class Base
      include BasePresentable
      include LaaMultiStepForms::CheckMissingHelper
      include ActionView::Helpers::UrlHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper

      # govuk_component required helpers
      include GovukVisuallyHiddenHelper
      include GovukLinkHelper
      include GovukComponentsHelper
      include GovukListHelper

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
          row_content(row[:head_key], row[:text], row[:head_opts] || {}, row[:actions])
        end
      end

      def request_method
        :edit
      end

      # :nocov:
      def template
        nil
      end
      # :nocov:

      # :nocov:
      def row_data
        raise 'Implement in subclass'
      end
      # :nocov:

      def row_content(head_key, text, head_opts = {}, actions = nil)
        heading = translate_table_key(section, head_key, **head_opts)
        key_value = {
          key: {
            text: heading,
          },
          value: {
            text:
          }
        }
        actions ? key_value.merge!(actions:) : key_value
      end

      def title_actions
        return [] if changes_forbidden?

        [
          govuk_link_to(
            I18n.t('generic.change'),
            change_action
          ),
        ]
      end

      def change_action
        helper = Rails.application.routes.url_helpers
        helper.url_for(controller: "prior_authority/steps/#{section}",
                       action: request_method,
                       application_id: application.id,
                       only_path: true,
                       return_to: :check_answers)
      end

      def section_link
        govuk_link_to(title, change_action)
      end

      def changes_forbidden?
        application.sent_back? && !application.correction_needed?
      end
    end
  end
end
