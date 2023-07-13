module CheckAnswers
  class HearingDetailsCard < Base
    attr_reader :hearing_details_form

    KEY = 'hearing_details'.freeze

    def initialize(claim)
      @hearing_details_form = Steps::HearingDetailsForm.build(claim)
    end

    def route_path
      KEY
    end

    def rows
      [
        {
          key: { text: translate_table_key(KEY, 'hearing_date'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: 'Test' }
        },
        {
          key: { text: translate_table_key(KEY, 'no_of_hearings'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: 'Test' }
        },
        {
          key: { text: translate_table_key(KEY, 'proceedings_concluded'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: 'Test' }
        },
        {
          key: { text: translate_table_key(KEY, 'youth_court'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: 'Test' }
        },
        {
          key: { text: translate_table_key(KEY, 'mag_court'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: 'Test' }
        },
        {
          key: { text: translate_table_key(KEY, 'hearing_outcome'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: 'Test' }
        },
        {
          key: { text: translate_table_key(KEY, 'matter_type'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: 'Test' }
        }
      ]
    end

    def title
      I18n.t('steps.check_answers.groups.about_case.hearing_details.title')
    end
  end
end
