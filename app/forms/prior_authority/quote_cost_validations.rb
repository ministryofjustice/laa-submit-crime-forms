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
        validate :items_within_limit
        validate :cost_per_item_within_limit
        validate :items_greater_than_zero

        validates :items,
                  numericality: { only_integer: true, allow_blank: true },
                  is_a_number: true
        validates :cost_per_item,
                  numericality: { allow_blank: true },
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

    def items_within_limit
      return unless items.present? && items.is_a?(Numeric)
      return unless items > NumericLimits::MAX_INTEGER

      errors.add(:items, :less_than_or_equal_to, count: NumericLimits::MAX_INTEGER, item_type: item_type.pluralize)
    end

    def cost_per_item_within_limit
      return unless cost_per_item.present? && cost_per_item.is_a?(Numeric)
      return unless cost_per_item > NumericLimits::MAX_FLOAT

      errors.add(:cost_per_item, :less_than_or_equal_to, count: NumericLimits::MAX_FLOAT,
                 item_type: translated_cost_item_type)
    end

    def items_greater_than_zero
      return unless items.present? && items.is_a?(Numeric)

      errors.add(:items, :greater_than, item_type: item_type.pluralize) if items.zero?
    end

    def translated_cost_item_type
      I18n.t("laa_crime_forms_common.prior_authority.service_costs.items.#{cost_item_type}")
    end

    def period_hours_within_limit
      validate_time_period_max_hours(:period, max_hours: NumericLimits::MAX_INTEGER)
    end
  end
end
