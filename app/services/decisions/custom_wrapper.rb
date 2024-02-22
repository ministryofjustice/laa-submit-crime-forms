module Decisions
  class CustomWrapper < SimpleDelegator
    def any_invalid?(scope, *forms)
      scope.detect { |record| forms.any? { |f| !f.build(record, application:).valid? } }
    end

    def overwrite_to_cya(destination: Decisions::PaDecisionTree::PRIOR_AUTHORITY_START_PAGE, action: :show)
      if application.navigation_stack.include?("/prior-authority/applications/#{application.id}/steps/check_answers")
        { edit: Decisions::PaDecisionTree::PRIOR_AUTHORITY_CHECK_ANSWERS }
      else
        { action => destination }
      end
    end
  end
end
