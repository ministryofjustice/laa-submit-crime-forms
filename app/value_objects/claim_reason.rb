class ClaimReason < ValueObject
  VALUES = [
    CORE_COSTS_EXCEED_HIGHER_LMTS = new(:core_costs_exceed_higher_limits),
    ENHANCED_RATES_CLAIMED    = new(:enhanced_rates_claimed),
    COUNCEL_OR_AGENT_ASSIGNED = new(:councel_or_agent_assigned),
    REPRESENTATION_ORDER_WITHDRAWN = new(:representation_order_withdrawn_on),
    EXTRADITION = new(:extradition),
    OTHER = new(:other),
  ].freeze
end
