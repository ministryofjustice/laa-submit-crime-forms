module PriorAuthority
  # We have these as a module rather than including in QuoteCostForm because the order in which
  # validations are declared matters and this gives the subclasses control of that.
  module QuoteCostValidations
    extend ActiveSupport::Concern

    DECIMAL_NUMBER_PATTERN = /\A-?(?:\d[\d,]*\.\d+|\.\d+)\z/

    included do
      validates :user_chosen_cost_type,
                inclusion: { in: PriorAuthority::Steps::QuoteCostForm::COST_TYPES, allow_nil: false },
                if: :variable_cost_type?

      with_options if: :per_item? do
        validate :validate_items
        validate :validate_cost_per_item
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

    def validate_items
      if items.blank?
        errors.add(:items, :blank, item_type: translated_item_type)
      elsif items.is_a?(String)
        errors.add(:items, decimal_number?(items) ? :not_a_whole_number : :not_a_number, item_type: translated_item_type)
      elsif items <= 0
        errors.add(:items, :greater_than, item_type: translated_item_type)
      elsif items > NumericLimits::MAX_INTEGER
        errors.add(:items, :less_than_or_equal_to, count: NumericLimits::MAX_INTEGER, item_type: translated_item_type)
      end
    end

    def validate_cost_per_item
      if cost_per_item.blank?
        errors.add(:cost_per_item, :blank, item_type: translated_cost_item_type)
      elsif cost_per_item.is_a?(String)
        errors.add(:cost_per_item, :not_a_number, item_type: translated_cost_item_type)
      elsif cost_per_item <= 0
        errors.add(:cost_per_item, :greater_than, item_type: translated_cost_item_type)
      elsif cost_per_item > NumericLimits::MAX_FLOAT
        errors.add(:cost_per_item, :less_than_or_equal_to, count: NumericLimits::MAX_FLOAT,
                   item_type: translated_cost_item_type)
      end
    end

    def translated_cost_item_type
      I18n.t("laa_crime_forms_common.prior_authority.service_costs.items.#{cost_item_type}")
    end

    def translated_item_type
      item_type.pluralize
    end

    def decimal_number?(value)
      value.delete(',').match?(DECIMAL_NUMBER_PATTERN)
    end

    def period_hours_within_limit
      validate_time_period_max_hours(:period, max_hours: NumericLimits::MAX_INTEGER)
    end
  end
end
