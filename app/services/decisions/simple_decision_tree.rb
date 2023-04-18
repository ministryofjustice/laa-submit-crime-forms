module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :claim_type
        after_claim_type
      end
    end

    def after_claim_type
      if form_object.claim_type.something_else?
        show('/claims', id: nil, action: :index)
      else
        edit(:firm_details)
      end
    end
  end
end