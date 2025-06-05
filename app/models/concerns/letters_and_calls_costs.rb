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

  def call_rate
    rates.letters_and_calls[:calls]
  end

  def letter_rate
    rates.letters_and_calls[:letters]
  end

  def letters_after_uplift
    letter_calculation[:claimed_total_exc_vat]
  end

  def calls_after_uplift
    call_calculation[:claimed_total_exc_vat]
  end

  def allowed_letters_after_uplift
    letter_calculation[:assessed_total_exc_vat]
  end

  def allowed_calls_after_uplift
    call_calculation[:assessed_total_exc_vat]
  end

  def letters_and_calls_total_cost
    return unless letters_after_uplift.positive? || calls_after_uplift.positive?

    current_total[:letters_and_calls][:claimed_total_exc_vat]
  end

  def letters_and_calls_total_cost_inc_vat
    current_total[:letters_and_calls][:claimed_total_inc_vat]
  end

  private

  def current_total
    # We can't reliably call `application.totals` because in the context
    # of a LettersCallsForm, the values here are not yet
    # necessarily the same as the values in the application
    # object.
    @current_total ||= LaaCrimeFormsCommon::Pricing::Nsm.totals(
      application.data_for_calculation.merge(
        letters_and_calls: letters_and_calls_for_calculation
      )
    )
  end

  def letters_before_uplift
    letter_calculation[:claimed_subtotal_without_uplift]
  end

  def calls_before_uplift
    call_calculation[:claimed_subtotal_without_uplift]
  end

  def letters_and_calls_for_calculation
    [letters_for_calculation, calls_for_calculation]
  end

  def calls_for_calculation
    {
      type: :calls,
      claimed_items: calls.to_i,
      claimed_uplift_percentage: apply_calls_uplift ? calls_uplift.to_i : 0,
      assessed_items: application.allowed_calls || calls.to_i,
      assessed_uplift_percentage: application.allowed_calls_uplift || calls_uplift.to_i,
    }
  end

  def letters_for_calculation
    {
      type: :letters,
      claimed_items: letters.to_i,
      claimed_uplift_percentage: apply_letters_uplift ? letters_uplift.to_i : 0,
      assessed_items: application.allowed_letters || letters || 0,
      assessed_uplift_percentage: application.allowed_letters_uplift || letters_uplift.to_i,
    }
  end

  def letter_calculation
    @letter_calculation ||= LaaCrimeFormsCommon::Pricing::Nsm.calculate_letter_or_call(
      application.data_for_calculation,
      letters_for_calculation
    )
  end

  def call_calculation
    @call_calculation ||= LaaCrimeFormsCommon::Pricing::Nsm.calculate_letter_or_call(
      application.data_for_calculation,
      calls_for_calculation
    )
  end
end
