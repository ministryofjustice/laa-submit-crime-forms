require 'steps/base_form_object'

module Steps
  class LettersCallsForm < Steps::BaseFormObject
    attr_writer :apply_uplift

    attribute :letters, :integer
    attribute :calls, :integer
    attribute :letters_calls_uplift, :integer

    validates :letters, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :calls, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :letters_calls_uplift, presence: true,
numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: :apply_uplift

    def apply_uplift
      @apply_uplift.nil? ? letters_calls_uplift.present? : @apply_uplift == 'true'
    end

    def letters_total
      letters.to_f * pricing.letters * (1 + (letters_calls_uplift.to_f / 100))
    end

    def calls_total
      calls.to_f * pricing.calls * (1 + (letters_calls_uplift.to_f / 100))
    end

    def total
      letters_total + calls_total
    end

    private

    def pricing
      @pricing ||= Pricing.for(application)
    end

    def persist!
      application.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge(letters_calls_uplift: apply_uplift ? letters_calls_uplift : nil)
    end
  end
end
