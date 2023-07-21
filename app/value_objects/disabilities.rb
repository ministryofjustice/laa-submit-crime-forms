class Disabilities < ValueObject
  VALUES = [
    YES = new(:y),
    NO = new(:n),
    UNKNOWN = new(:u)
  ].freeze
end
