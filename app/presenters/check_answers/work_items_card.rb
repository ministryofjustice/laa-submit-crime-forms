module CheckAnswers
  class WorkItemsCard
    def initialize(claim)
    
    end

    def route_path
      "work_items"
    end
    
    def title
      I18n.t('steps.check_answers.groups.about_claim.work_items.title')
    end
  end
end
