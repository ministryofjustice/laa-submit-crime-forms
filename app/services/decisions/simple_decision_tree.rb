module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    EDIT_MAPPING = {
      firm_details: :case_details,
      case_details: :case_disposal,
      case_disposal: :hearing_details,
      hearing_details: :defendant_details,
      defendant_details: :defendant_summary,
      defendant_delete: :defendant_summary,
    }.freeze

    SHOW_MAPPING = {
      reason_for_claim: :start_page,
    }.freeze

    def destination
      case step_name
      when :claim_type then after_claim_type
      when :defendant_summary then after_defendants
      when *EDIT_MAPPING.keys then edit(EDIT_MAPPING[step_name])
      when *SHOW_MAPPING.keys then show(SHOW_MAPPING[step_name])

      else
        index('/claims')
      end
    end

    def after_claim_type
      if form_object.claim_type.supported?
        show(:start_page)
      else
        index('/claims')
      end
    end

    def after_defendants
      if form_object.add_another.yes?
        next_posiiton = form_object.application.defendants.maximum(:position) + 1
        new_defendant = form_object.application.defendants.create(position: next_posiiton)
        edit(:defendant_details, defendant_id: new_defendant.id)
      else
        edit(:reason_for_claim)
      end
    end
  end
end
