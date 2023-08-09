module LaaMultiStepForms
  module CheckMissingHelper
    def check_missing(check_value)
      if check_value.present?
        return yield if block_given?

        check_value
      else
        ApplicationController.helpers.sanitize(
          content_tag(:strong, I18n.t('helpers.missing_data'), class: 'govuk-tag govuk-tag--red'),
          tags: %w[strong]
        )
      end
    end
  end
end
