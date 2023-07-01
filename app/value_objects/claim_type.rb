class ClaimType < ValueObject
  VALUES = [
    NON_STANDARD_MAGISTRATE = new(:non_standard_magistrate),
    BREACH_OF_INJUNCTION    = new(:breach_of_injunction),
  ].freeze

  SUPPORTED = [
    NON_STANDARD_MAGISTRATE,
    BREACH_OF_INJUNCTION,
  ].freeze

  def supported?
    SUPPORTED.include?(self)
  end
end
