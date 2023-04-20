module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :claim_type
        after_claim_type
      when :firm_details
        index(:claims)
        # edit(:reason_for_claim)
      else
        index(:claims)
      end
    end

    def after_claim_type
      if form_object.claim_type.supported?
        edit(:firm_details)
      else
        index(:claims)
      end
    end
  end
end
