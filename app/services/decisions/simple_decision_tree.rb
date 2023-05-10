module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :claim_type
        after_claim_type
      when :firm_details
        edit(:case_disposal)
      when :case_disposal
        after_case_disposal
      when :guilty_plea
        index('/claims', a: 1)
      else
        index('/claims')
      end
    end

    def after_claim_type
      if form_object.claim_type.supported?
        edit(:firm_details)
      else
        index('/claims')
      end
    end

    def after_case_disposal
      if form_object.plea == Plea::GUILTY
        edit(:guilty_plea)
      else
        index('/claims')
      end
    end
  end
end
