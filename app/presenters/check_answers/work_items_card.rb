module CheckAnswers
  class WorkItemsCard < Base
    def initialize(claim)
    
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.work_items.title')
    end
  end
end
