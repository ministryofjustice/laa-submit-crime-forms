module CheckAnswers
  class WorkItemsCard
    attr_reader :work_item_form

    def initialize(claim)
      # @work_item_form = Steps::WorkItemForm.build(claim)
    end

    def route_path
      'work_items'
    end

    def title
      I18n.t('steps.check_answers.groups.about_claim.work_items.title')
    end
  end
end
