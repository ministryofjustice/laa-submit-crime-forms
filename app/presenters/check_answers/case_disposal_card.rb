module CheckAnswers
  class CaseDisposalCard < Base
    def initialize(claim)
    
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_case.case_disposal.title')
    end
  end
end
