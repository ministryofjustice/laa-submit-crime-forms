class DisbursementTypes < ValueObject
  VALUES = [
    CAR = new(:car),
    MOTORCYCLE = new(:motorcycle),
    BIKE = new(:bike),
    OTHER = new(:other),
  ].freeze
end
