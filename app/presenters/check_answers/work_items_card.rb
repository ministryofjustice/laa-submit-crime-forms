module CheckAnswers
  class WorkItemsCard < Base
    attr_reader :work_item_form

    KEY = 'work_items'.freeze
    GROUP = 'about_claim'.freeze

    def initialize(_claim)
      # @work_item_form = Steps::WorkItemForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      'work_items'
    end
  end
end
