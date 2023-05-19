module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :claim_type
        after_claim_type
      when :firm_details
        edit(:case_details)
      when :case_details
        edit(:case_disposal)
      when :case_disposal
        edit(:hearing_details)
      when :hearing_details
        show(:start_page)
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
  end
end
