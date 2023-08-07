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
          text: case_details_form.main_offence
        },
        {
          head_key: 'main_offence_date',
          text: case_details_form.main_offence_date.strftime('%d %B %Y')
        },
        {
          head_key: 'assigned_counsel',
          text: capitalize_sym(case_details_form.assigned_counsel)
        },
        {
          head_key: 'unassigned_counsel',
          text: capitalize_sym(case_details_form.unassigned_counsel)
        },
        {
          head_key: 'agent_instructed',
          text: capitalize_sym(case_details_form.agent_instructed)
        },
        {
          head_key: 'remitted_to_magistrate',
          text: capitalize_sym(case_details_form.remitted_to_magistrate)
        },
      ]
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
