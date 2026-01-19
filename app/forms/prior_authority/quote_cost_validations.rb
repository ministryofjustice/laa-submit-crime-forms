module PriorAuthority
  # We have these as a module rather than including in QuoteCostForm because the order in which
  # validations are declared matters and this gives the subclasses control of that.
  module QuoteCostValidations
    extend ActiveSupport::Concern

    included do
      validates :user_chosen_cost_type,
                inclusion: { in: PriorAuthority::Steps::QuoteCostForm::COST_TYPES, allow_nil: false },
                if: :variable_cost_type?

      with_options if: :per_item? do
        validates :items, item_type_dependant: true
        validates :cost_per_item, cost_item_type_dependant: true

        validates :items,
                  numericality: { only_integer: true, greater_than: 0,
                                  less_than_or_equal_to: NumericLimits::MAX_INTEGER, allow_blank: true },
                  is_a_number: true
        validates :cost_per_item,
                  numericality: { greater_than: 0, less_than_or_equal_to: NumericLimits::MAX_FLOAT, allow_blank: true },
                  is_a_number: true
      end

      with_options if: :per_hour? do
        validates :period, presence: true, time_period: true
        validate :period_hours_within_limit
        validates :cost_per_hour, presence: true,
                  numericality: { greater_than: 0, less_than_or_equal_to: NumericLimits::MAX_FLOAT },
                  is_a_number: true
      end
    end

    private

    def period_hours_within_limit
      validate_time_period_max_hours(:period, max_hours: NumericLimits::MAX_INTEGER)
    end
  end
end
