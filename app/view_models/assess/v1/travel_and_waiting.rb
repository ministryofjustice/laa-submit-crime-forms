module Assess
  module V1
    class TravelAndWaiting < Assess::BaseViewModel
      include V1::WorkItemSummary

      INCLUDED_TYPES = %w[travel waiting].freeze

      attribute :claim

      def table_fields
        work_item_data.map do |work_type, total_cost, total_time_spent|
          [
            work_type,
            NumberTo.pounds(total_cost),
            "#{total_time_spent}min",
          ]
        end
      end

      def total_cost
        NumberTo.pounds(
          work_item_data.sum { |_, total_cost, _| total_cost }
        )
      end

      delegate :any?, to: :work_item_data

      private

      def skip_work_item?(work_item)
        INCLUDED_TYPES.exclude?(work_item.work_type.value)
      end
    end
  end
end
