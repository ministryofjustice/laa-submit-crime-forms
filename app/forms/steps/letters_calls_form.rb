require 'steps/base_form_object'

module Steps
  class LettersCallsForm < Steps::BaseFormObject
    attribute :letters, :integer
    attribute :calls, :integer
    attribute :letters_calls_uplift, :integer

    validates :letters, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :calls, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :calls, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, if: :apply_uplift

    def apply_uplift
      @apply_uplift.nil? ? letters_calls_uplift.present? : @apply_uplift
    end

    def apply_uplift=(val)
      @apply_uplift = val
    end

    def period
      if application.date < Date.new(2022, 9, 30)
        :period_pre_sep_22
      else
        :period_post_sep_22
      end
    end

    def price_per
      {
        period_pre_sep_22: 3.56,
        period_post_sep_22: 4.09,
      }[period]
    end

    def letters_total
      letters.to_f * price_per * (1 + letters_calls_uplift.to_f / 100)
    end

    def calls_total
      calls.to_f * price_per * (1 + letters_calls_uplift.to_f / 100)
    end

    def total
      letters_total + calls_total
    end

    private

    def persist!
      application.update!(attributes_with_resets)
    end

    def attributes_with_resets
      attributes.merge(letters_calls_uplift: apply_uplift ? letters_calls_uplift : nil)
    end
  end
end
