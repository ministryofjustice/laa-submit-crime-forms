module Nsm
  module Tasks
    class Base < ::Tasks::Generic
      DECISION_TREE = Decisions::NsmDecisionTree
    end
  end
end
