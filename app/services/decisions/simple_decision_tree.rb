module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :claim_type
        after_claim_type
          when :firm_details
          edit(:claim_reason)
      else
        index(:claims)
      end
    end

    def after_claim_type
      if form_object.claim_type.supported?
        edit(:firm_details)
      else
        index(:claim_reason)
      end
    end
  end
end
