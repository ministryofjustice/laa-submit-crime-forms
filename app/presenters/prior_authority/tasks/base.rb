module PriorAuthority
  module Tasks
    class Base < ::Tasks::Generic
      DECISION_TREE = Decisions::PaDecisionTree

      def default_url_options
        { application_id: application }
      end
    end
  end
end
