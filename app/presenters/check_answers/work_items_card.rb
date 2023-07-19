# frozen_string_literal: true

module CheckAnswers
  class WorkItemsCard < Base
    attr_reader :work_item_form

    def initialize(_claim)
      @group = 'about_claim'
      @section = 'work_items'
    end
  end
end
