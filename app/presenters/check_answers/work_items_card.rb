# frozen_string_literal: true

module CheckAnswers
  class WorkItemsCard < Base
    include CostSummary
    attr_reader :work_items

    def initialize(claim)
      @work_items = WorkItems.new(claim.work_items, claim)
      @group = 'about_claim'
      @section = 'work_items'
    end

    def row_data
      header_rows + work_items.rows.map do |row|
        {
          head_key: row[:head_key],
          text: row[:value][:text]
        }
      end
    end

    private

    def header_rows
      [
        {
          head_key: 'items',
          text: ActionController::Base.helpers.sanitize(translate_table_key(section, 'items_total'), tags: %w[strong])
        }
      ]
    end
  end
end
