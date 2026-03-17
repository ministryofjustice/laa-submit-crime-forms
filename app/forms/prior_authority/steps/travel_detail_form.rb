module PriorAuthority
  module Steps
    class TravelDetailForm < ::Steps::BaseFormObject
      attribute :travel_cost_reason, :string
      attribute :travel_time, :time_period
      attribute :travel_cost_per_hour, :gbp

      validates :travel_cost_reason, presence: true, if: :travel_costs_require_justification?
      validates :travel_time, presence: true, time_period: true
      validate :travel_time_hours_within_limit
      validates :travel_cost_per_hour, presence: true, numericality: { greater_than: 0 }, is_a_number: true
      validate :travel_cost_per_hour_within_limit

      def travel_costs_require_justification?
        !application.prison_law && !application.client_detained
      end

      def travel_costs_added?
        travel_cost_per_hour.present? || travel_time.present?
      end

      def formatted_total_cost
        LaaCrimeFormsCommon::NumberTo.pounds(total_cost)
      end

      def total_cost
        return 0 if travel_time.is_a?(Hash)
        return 0 if travel_cost_per_hour.is_a?(String)
        return 0 unless travel_cost_per_hour.to_i.positive? && travel_time.to_i.positive?

        (travel_cost_per_hour * (travel_time.hours + (travel_time.minutes / 60.0))).round(2)
      end

      def adjusted_cost
        record.travel_cost_allowed
      end

      def empty?
        !valid? && travel_cost_reason.blank? && travel_time.blank? && travel_cost_per_hour.blank?
      end

      private

      def persist!
        record.update!(attributes)
      end

      def travel_time_hours_within_limit
        return unless travel_time.present? && !travel_time.is_a?(Hash) && travel_time.respond_to?(:hours)
        return unless travel_time.hours.to_i > NumericLimits::MAX_INTEGER

        errors.add(:travel_time, :max_hours, count: NumericLimits::MAX_INTEGER)
      end

      def travel_cost_per_hour_within_limit
        return unless travel_cost_per_hour.present? && travel_cost_per_hour.is_a?(Numeric)
        return unless travel_cost_per_hour > NumericLimits::MAX_FLOAT

        errors.add(:travel_cost_per_hour, :less_than_or_equal_to, count: NumericLimits::MAX_FLOAT)
      end
    end
  end
end
