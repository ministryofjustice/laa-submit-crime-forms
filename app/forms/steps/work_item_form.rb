require 'steps/base_form_object'

module Steps
  class WorkItemForm < Steps::BaseFormObject
    attr_writer :apply_uplift

    attribute :work_type, :string
    attribute :hours, :integer
    attribute :minutes, :integer
    attribute :completed_on, :multiparam_date
    attribute :fee_earner, :string
    attribute :uplift, :integer

    validates :work_type, presence: true
    validates :hours, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :minutes, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :rep_order_date, presence: true,
            multiparam_date: { allow_past: true, allow_future: false }
    validates :fee_earner, presence: true
    validates :letters_calls_uplift, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: :apply_uplift

    def apply_uplift
      @apply_uplift.nil? ? uplift.present? : @apply_uplift == 'true'
    end

    def pricing
      @pricing ||= Pricing.for(application)
    end

    def total
      (hours.to_f + (minutes.to_f / 60)) * pricing[worktype]
    end

    private

    def persist!
      application.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge(uplift: apply_uplift ? uplift : nil)
    end
  end
end
