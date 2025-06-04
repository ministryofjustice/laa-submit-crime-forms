module LaaMultiStepForms
  module CheckMissingHelper
    def check_missing(check_value, formatted_value = nil)
      if check_value.nil? || check_value == ''
        missing_tag
      else
        return yield if block_given?

        check_value = YesNoAnswer::YES.to_s.capitalize if check_value == true
        check_value = YesNoAnswer::NO.to_s.capitalize if check_value == false

        formatted_value || check_value
      end
    end

    def missing_tag
      ApplicationController.helpers.sanitize(
        content_tag(:strong, I18n.t('helpers.missing_data'), class: 'govuk-tag govuk-tag--red'),
        tags: %w[strong]
      )
    end
  end
end
