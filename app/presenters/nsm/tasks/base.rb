module Nsm
  module Tasks
    class Base < ::Tasks::Generic
      DECISION_TREE = Decisions::DecisionTree
    end
  end
end
