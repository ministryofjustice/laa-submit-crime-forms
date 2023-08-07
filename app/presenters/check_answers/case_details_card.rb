# frozen_string_literal: true

module CheckAnswers
  class CaseDetailsCard < Base
    attr_reader :case_details_form

    def initialize(claim)
      @case_details_form = Steps::CaseDetailsForm.build(claim)
      @group = 'about_case'
      @section = 'case_details'
    end

    # TO DO: update remittal to include date of remittal when CRM457-172 is done
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def row_data
      [
        {
          head_key: 'main_offence',
          text: check_missing(case_details_form.main_offence)
        },
        {
          head_key: 'main_offence_date',
          text: check_missing(case_details_form.main_offence_date) do
                  case_details_form.main_offence_date.strftime('%d %B %Y')
                end
        },
        {
          head_key: 'assigned_counsel',
          text: check_missing(case_details_form.assigned_counsel.present?) do
                  capitalize_sym(case_details_form.assigned_counsel)
                end
        },
        {
          head_key: 'unassigned_counsel',
          text: check_missing(case_details_form.unassigned_counsel.present?) do
                  capitalize_sym(case_details_form.unassigned_counsel)
                end
        },
        {
          head_key: 'agent_instructed',
          text: check_missing(case_details_form.agent_instructed.present?) do
                  capitalize_sym(case_details_form.agent_instructed)
                end
        },
        {
          head_key: 'remitted_to_magistrate',
          text: check_missing(case_details_form.remitted_to_magistrate.present?) do
                  capitalize_sym(case_details_form.remitted_to_magistrate)
                end
        },
      ]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
