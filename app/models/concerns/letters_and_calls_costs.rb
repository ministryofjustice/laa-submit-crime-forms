module LettersAndCallsCosts
  extend ActiveSupport::Concern

  included do
    define_method(:application) { self } if self == ::Claim
  end

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

  def letters_after_uplift
    if apply_letters_uplift && letters_before_uplift
      letters_before_uplift * (1 + (letters_uplift.to_d / 100))
    elsif letters_before_uplift&.positive?
      letters_before_uplift
    end
  end

  def calls_after_uplift
    if apply_calls_uplift && calls_before_uplift
      calls_before_uplift * (1 + (calls_uplift.to_d / 100))
    elsif calls_before_uplift&.positive?
      calls_before_uplift
    end
  end

  def allowed_letters_after_uplift
    (allowed_letters || letters).to_d * pricing.letters * (1 + ((allowed_letters_uplift || letters_uplift).to_d / 100))
  end

  def allowed_calls_after_uplift
    (allowed_calls || calls).to_d * pricing.calls * (1 + ((allowed_calls_uplift || calls_uplift).to_d / 100))
  end

  def letters_and_calls_total_cost
    return unless letters_after_uplift&.positive? || calls_after_uplift&.positive?

    letters_after_uplift.to_d + calls_after_uplift.to_d
  end

  def letters_and_calls_total_cost_inc_vat
    (letters_and_calls_total_cost * pricing.vat) + letters_and_calls_total_cost
  end

  private

  def letters_before_uplift
    letters.to_d * pricing.letters if letters && !letters.zero?
  end

  def calls_before_uplift
    calls.to_d * pricing.letters if calls && !calls.zero?
  end
end
