class Genders < ValueObject
  VALUES = [
    MALE = new(:m),
    FEMALE = new(:f),
    UNKNOWN = new(:u)
  ].freeze
end
