class ClaimType < ValueObject
  VALUES = [
    NON_STANDARD_MAGISTRATE = new(:non_standard_magistrate),
    BREACH_OF_INJUNCTION    = new(:breach_of_injunction),
  ].freeze
end
