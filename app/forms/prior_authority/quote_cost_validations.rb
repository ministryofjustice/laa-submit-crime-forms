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
        validate :validate_item_count
        validate :validate_item_cost
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

    def validate_item_count
      return add_item_count_error(:blank) if items.blank?
      return add_item_count_error(item_count_string_error) if items.is_a?(String)
      return add_item_count_error(:greater_than) if items <= 0

      add_item_count_error(:less_than_or_equal_to, count: NumericLimits::MAX_INTEGER) if items > NumericLimits::MAX_INTEGER
    end

    def validate_item_cost
      return add_item_cost_error(:blank) if cost_per_item.blank?
      return add_item_cost_error(:not_a_number) if cost_per_item.is_a?(String)
      return add_item_cost_error(:greater_than) if cost_per_item <= 0
      return unless cost_per_item > NumericLimits::MAX_FLOAT

      add_item_cost_error(:less_than_or_equal_to, count: NumericLimits::MAX_FLOAT)
    end

    def add_item_count_error(error, **)
      errors.add(:items, error, item_type: item_type_label, **)
    end

    def add_item_cost_error(error, **)
      errors.add(:cost_per_item, error, item_type: cost_item_type_label, **)
    end

    def item_count_string_error
      decimal_input?(items) ? :not_a_whole_number : :not_a_number
    end

    def item_type_label
      item_type.pluralize
    end

    def cost_item_type_label
      I18n.t("laa_crime_forms_common.prior_authority.service_costs.items.#{cost_item_type}")
    end

    def decimal_input?(value)
      normalized_value = value.delete(',').strip
      return false if normalized_value.blank?

      Integer(normalized_value, exception: false).nil? &&
        !BigDecimal(normalized_value, exception: false).nil?
    end

    def period_hours_within_limit
      validate_time_period_max_hours(:period, max_hours: NumericLimits::MAX_INTEGER)
    end
  end
end
