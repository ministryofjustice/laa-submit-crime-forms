# OPTMIZE: share with nsm via concern or inheritance?
module PriorAuthority
  module CheckAnswers
    class Base
      include LaaMultiStepForms::CheckMissingHelper
      include ActionView::Helpers::UrlHelper
      include GovukLinkHelper
      include GovukVisuallyHiddenHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper

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
