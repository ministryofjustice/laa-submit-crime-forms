module PriorAuthority
  module Steps
    class DeleteTravelForm < TravelDetailForm
      def valid?
        true
      end

      private

      def persist!
        application.update!(
          travel_cost_reason: nil,
          travel_time: nil,
          travel_cost_per_hour: nil
        )

        true
      end
    end
  end
end
