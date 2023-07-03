require 'steps/base_form_object'

module Steps
  class LettersCallsForm < Steps::BaseFormObject
    attr_writer :apply_calls_uplift, :apply_letters_uplift

    attribute :letters, :integer
    attribute :calls, :integer
    attribute :letters_uplift, :integer
    attribute :calls_uplift, :integer

    validates :letters, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :calls, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :letters_uplift, presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: :apply_letters_uplift
    validates :calls_uplift, presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: :apply_calls_uplift

    def allow_uplift?
      application.reasons_for_claim.include?(ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s)
    end

    def apply_calls_uplift
      allow_uplift? &&
        (@apply_calls_uplift.nil? ? calls_uplift.present? : @apply_calls_uplift == 'true')
    end

    def apply_letters_uplift
      allow_uplift? &&
        (@apply_letters_uplift.nil? ? letters_uplift.present? : @apply_letters_uplift == 'true')
    end

    def letters_total
      letters.to_f * pricing.letters * (1 + (letters_uplift.to_f / 100))
    end

    def calls_total
      calls.to_f * pricing.calls * (1 + (calls_uplift.to_f / 100))
    end

    def total_cost
      letters_total + calls_total
    end

    def pricing
      @pricing ||= Pricing.for(application)
    end

    private

    def persist!
      application.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge(
        'letters_uplift' => apply_letters_uplift ? letters_uplift : nil,
        'calls_uplift' => apply_calls_uplift ? calls_uplift : nil,
      )
    end
  end
end
