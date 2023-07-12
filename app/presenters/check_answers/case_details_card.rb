module CheckAnswers
  class CaseDetailsCard < Base
    attr_reader :case_details_form
    
    KEY = "case_details"

    def initialize(claim)
      @case_details_form = Steps::CaseDetailsForm.build(claim)
    end

    def route_path
      KEY
    end

    def title
      I18n.t('steps.check_answers.groups.about_case.case_details.title')
    end

    #TO DO: update remittal to include date of remittal when CRM457-172 is done
    def rows
      [
        {
          key: { text: translate_table_key(KEY, 'main_offence'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: case_details_form.main_offence },
        },
        {
          key: { text: translate_table_key(KEY, 'main_offence_date'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: case_details_form.main_offence_date&.strftime('%d %B %Y') },
        },
        {
          key: { text: translate_table_key(KEY, 'assigned_counsel'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: case_details_form.assigned_counsel.value.capitalize },
        },
        {
          key: { text: translate_table_key(KEY, 'unassigned_counsel'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: case_details_form.unassigned_counsel.value.capitalize },
        },
        {
          key: { text: translate_table_key(KEY, 'agent_instructed'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: case_details_form.agent_instructed.value.capitalize },
        },
        {
          key: { text: translate_table_key(KEY, 'remitted_to_magistrate'), classes: 'govuk-summary-list__value-width-50' },
          value: { text: case_details_form.remitted_to_magistrate.value.capitalize },
        }
      ]
    end
  end
end
