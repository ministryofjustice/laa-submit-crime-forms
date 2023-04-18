module Decisions
  class SimpleDecisionTree < BaseDecisionTree
    def destination
      case step_name
      when :claiming_type
        edit(:firm_details)
      end
    end
  end
end