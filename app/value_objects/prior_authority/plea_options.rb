module PriorAuthority
  class PleaOptions < ValueObject
    VALUES = [
      GUILTY = new(:guilty),
      NOT_GUILTY = new(:not_guilty),
      MIXED = new(:mixed),
      UNKNOWN = new(:unknown)
    ].freeze
  end
end
