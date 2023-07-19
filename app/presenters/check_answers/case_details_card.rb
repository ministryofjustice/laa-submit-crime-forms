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
    def row_data
      {
        main_offence: { text: case_details_form.main_offence },
        main_offence_date: { text: case_details_form.main_offence_date&.strftime('%d %B %Y') },
        assigned_counsel: { text: capitalize_sym(case_details_form.assigned_counsel) },
        unassigned_counsel: { text: capitalize_sym(case_details_form.unassigned_counsel) },
        agent_instructed: { text: capitalize_sym(case_details_form.agent_instructed) },
        remitted_to_magistrate: { text: capitalize_sym(case_details_form.remitted_to_magistrate) },
      }
    end
  end
end
