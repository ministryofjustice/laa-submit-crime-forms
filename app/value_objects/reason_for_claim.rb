class ReasonForClaim < ValueObject
  VALUES = [
    CORE_COSTS_EXCEED_HIGHER_LMTS = new(:core_costs_exceed_higher_limit),
    ENHANCED_RATES_CLAIMED    = new(:enhanced_rates_claimed),
    COUNCEL_OR_AGENT_ASSIGNED = new(:councel_or_agent_assigned),
    REPRESENTATION_ORDER_WITHDRAWN = new(:representation_order_withdrawn, date_field: :representation_order_withdrawn),
    EXTRADITION = new(:extradition),
    OTHER = new(:other, text_field: :reason_for_claim_other_details),
  ].freeze

  attr_reader :date_field, :text_field

  def initialize(raw_value, date_field:, text_field:)
    super(raw_value)
    @date_field = date_field
    @text_field = text_field
  end

  def date_field?
    date_field.nil?
  end

  def text_field?
    text_field.present?
  end
end
