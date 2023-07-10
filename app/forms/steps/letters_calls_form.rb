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
      numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
      if: :apply_letters_uplift
    validates :calls_uplift, presence: true,
      numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 },
      if: :apply_calls_uplift

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

    def pricing
      @pricing ||= Pricing.for(application)
    end

    def calculation_rows
      [
        [translate(:items), translate(:before_uplift), translate(:after_uplift)],
        letters_row,
        calls_row,
      ]
    end

    def letters_after_uplift
      if apply_letters_uplift && letters_before_uplift
        letters_before_uplift * (1 + (letters_uplift.to_f / 100))
      else
        letters_before_uplift
      end
    end

    def calls_after_uplift
      if apply_calls_uplift && calls_before_uplift
        calls_before_uplift * (1 + (calls_uplift.to_f / 100))
      else
        calls_before_uplift
      end
    end

    def total_cost
      letters_after_uplift + calls_after_uplift
    end

    private

    def letters_row
      [
        translate(:letters),
        {
          text: NumberTo.pounds(letters_before_uplift),
          html_attributes: { id: 'letters-without-uplift' }
        },
        {
          text: NumberTo.pounds(letters_after_uplift),
          html_attributes: { id: 'letters-with-uplift' },
        }
      ]
    end

    def calls_row
      [
        translate(:calls),
        {
          text: NumberTo.pounds(calls_before_uplift),
          html_attributes: { id: 'calls-without-uplift' }
        },
        {
          text: NumberTo.pounds(calls_after_uplift),
          html_attributes: { id: 'calls-with-uplift' },
        }
      ]
    end

    def translate(key)
      I18n.t("steps.letters_calls.edit.#{key}")
    end

    def persist!
      application.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge(
        'letters_uplift' => apply_letters_uplift ? letters_uplift : nil,
        'calls_uplift' => apply_calls_uplift ? calls_uplift : nil,
      )
    end

    def letters_before_uplift
      letters.to_f * pricing.letters if letters
    end

    def calls_before_uplift
      calls.to_f * pricing.letters if calls
    end
  end
end
