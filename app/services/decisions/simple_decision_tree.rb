module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    EDIT_MAPPING = {
      firm_details: :case_details,
      case_details: :case_disposal,
      case_disposal: :hearing_details,
      hearing_details: :defendant_details,
      delete_defendant: :defendant_details,
      defendant_details:  :reason_for_claim,
    }.freeze

    SHOW_MAPPING = {
      reason_for_claim: :start_page,
    }.freeze

    def destination
      case step_name
      when :claim_type then after_claim_type
      when :add_defendant then add_defendant
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

    def add_defendant
      form_object.application.defendants.create(position: form_object.next_position)
      edit(:defendant_details)
    end
  end
end
