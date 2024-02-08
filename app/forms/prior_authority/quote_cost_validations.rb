module PriorAuthority
  # We have these as a module rather than including in QuoteCostForm because the order in which
  # validations are declared matters and this gives the subclasses control of that.
  module QuoteCostValidations
    extend ActiveSupport::Concern

    included do
      validates :user_chosen_cost_type,
                inclusion: { in: PriorAuthority::Steps::QuoteCostForm::COST_TYPES, allow_nil: false },
                if: :variable_cost_type?

      validates :items, presence: true, numericality: { greater_than: 0 }, if: :per_item?
      validates :cost_per_item, presence: true, numericality: { greater_than: 0 }, if: :per_item?

      validates :period, presence: true, time_period: true, if: :per_hour?
      validates :cost_per_hour, presence: true, numericality: { greater_than: 0 }, if: :per_hour?
    end
  end
end
