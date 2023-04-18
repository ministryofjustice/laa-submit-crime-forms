class ClaimType < ValueObject
  VALUES = [
    NON_STANDARD_MAGISTRATE = new(:non_standard_magistrate),
    BREACH_OF_INJUNCTION    = new(:breach_of_injunction),
    SOMETHING_ELSE          = new(:something_else),
  ].freeze

  SUPPORTED = [
    NON_STANDARD_MAGISTRATE,
    BREACH_OF_INJUNCTION,
  ].freeze

  def supported?
    SUPPORTED.include?(self)
  end
end
