module Decisions
  class CustomWrapper < SimpleDelegator
    def any_invalid?(scope, *forms)
      scope.detect { |record| forms.any? { |f| !f.build(record, application:).valid? } }
    end

    def source_was_check_answers?(rule, any_source: false)
      (
        any_source ||
        rule.process[0] == { show: Decisions::DecisionTree::PRIOR_AUTHORITY_START_PAGE }
      ) && application.navigation_stack.include?("/prior-authority/applications/#{application.id}/steps/check_answers")
    end
  end
end
