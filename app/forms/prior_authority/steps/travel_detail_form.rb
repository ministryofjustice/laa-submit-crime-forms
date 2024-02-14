module PriorAuthority
  module Steps
    class TravelDetailForm < ::Steps::BaseFormObject
      attribute :travel_cost_reason, :string
      attribute :travel_time, :time_period
      attribute :travel_cost_per_hour, :decimal, precision: 10, scale: 2

      validates :travel_cost_reason, presence: true, if: :travel_costs_require_justification?
      validates :travel_time, presence: true, time_period: true
      validates :travel_cost_per_hour, presence: true, numericality: { greater_than: 0 }

      def travel_costs_require_justification?
        !application.prison_law && !application.client_detained
      end

      def formatted_total_cost
        NumberTo.pounds(total_cost)
      end

      def total_cost
        return 0 unless travel_cost_per_hour.to_i.positive? && travel_time.to_i.positive?

        (travel_cost_per_hour * (travel_time.hours + (travel_time.minutes / 60.0))).round(2)
      end

      private

      def persist!
        record.update!(attributes)
      end
    end
  end
end
