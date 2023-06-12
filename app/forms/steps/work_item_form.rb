require 'steps/base_form_object'

module Steps
  class WorkItemForm < Steps::BaseFormObject
    attr_writer :apply_uplift

    attribute :id, :string
    attribute :work_type, :value_object, source: WorkTypes
    attribute :time_spent, :time_period
    attribute :completed_on, :multiparam_date
    attribute :fee_earner, :string
    attribute :uplift, :integer

    validates :work_type, presence: true
    validates :time_spent, presence: true, time_period: true
    validates :completed_on, presence: true,
            multiparam_date: { allow_past: true, allow_future: false }
    validates :fee_earner, presence: true
    validates :uplift, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
            if: :apply_uplift

    def apply_uplift
      @apply_uplift.nil? ? uplift.present? : @apply_uplift == 'true'
    end

    def pricing
      @pricing ||= Pricing.for(application)
    end

    def total_cost
      time_spent.try(:valid?) ? apply_uplift!(time_spent.to_f / 60) * pricing[work_type] : nil
    end

    def work_types_with_pricing
      WorkTypes.values.map do |value|
        [value, pricing[value.to_s]]
      end
    end

    private

    def apply_uplift!(val)
      (1.0 + (apply_uplift ? (uplift.to_f / 100) : 0)) * val
    end

    def persist!
      record.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge(uplift: apply_uplift ? uplift : nil)
    end
  end
end
