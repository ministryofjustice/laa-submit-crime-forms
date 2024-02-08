# OPTMIZE: share with nsm via concern or inheritance?
module PriorAuthority
  module CheckAnswers
    class Base
      include LaaMultiStepForms::CheckMissingHelper
      include ActionView::Helpers::TagHelper

      attr_accessor :group, :section

      delegate :sanitize, to: 'ApplicationController.helpers'

      def translate_table_key(section, key, **)
        I18n.t("prior_authority.steps.check_answers.show.sections.#{section}.#{key}", **)
      end

      def title(**)
        I18n.t("prior_authority.steps.check_answers.groups.#{group}.#{section}.title", **)
      end

      def rows
        row_data.map do |row|
          row_content(row[:head_key], row[:text], row[:head_opts] || {})
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

      def row_content(head_key, text, head_opts = {})
        heading = translate_table_key(section, head_key, **head_opts)

        {
          key: {
            text: heading,
            classes: 'govuk-summary-list__value-width-50'
          },
          value: {
            text:
          }
        }
      end
    end
  end
end
