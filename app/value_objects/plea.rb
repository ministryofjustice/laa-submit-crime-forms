class Plea < ValueObject
  VALUES = [
    GUILTY = new(:guilty),
    NOT_GUILTY = new(:not_guilty),
  ].freeze
end
