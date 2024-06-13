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
        validates :items, item_type_dependant: { pluralize: true }
        validates :cost_per_item, cost_item_type_dependant: true
      end

      with_options if: :per_hour? do
        validates :period, presence: true, time_period: true
        validates :cost_per_hour, presence: true, numericality: { greater_than: 0 }, is_a_number: true
      end
    end
  end
end
