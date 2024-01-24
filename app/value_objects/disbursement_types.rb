class DisbursementTypes < ValueObject
  include ActionView::Helpers::NumberHelper

  VALUES = [
    CAR = new(:car),
    MOTORCYCLE = new(:motorcycle),
    BIKE = new(:bike),
    OTHER = new(:other),
  ].freeze

  def hint(application)
    rate = Pricing.for(application)[value]
    I18n.t(translation_key, rate: number_to_currency(rate, unit: '£')) if rate
  end

  def translation_key
    [
      'helpers',
      'hint',
      'nsm_steps_disbursement_type_form',
      'disbursement_type_options',
      value
    ].join('.')
  end
end
