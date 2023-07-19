# frozen_string_literal: true

module CheckAnswers
  class WorkItemsCard < Base
    attr_reader :work_item_form

    KEY = 'work_items'
    GROUP = 'about_claim'

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
