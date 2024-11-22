class PleaCategory < ValueObject
  WITH_YOUTH_COURT_OPTIONS = [
    CATEGORY_1A = new(:category_1a),
    CATEGORY_1B = new(:category_1b),
    CATEGORY_2A = new(:category_2a),
    CATEGORY_2B = new(:category_2b),
  ].freeze

  WITHOUT_YOUTH_COURT_OPTIONS = [
    CATEGORY_1A,
    CATEGORY_1B,
    CATEGORY_2 = new(:category_2),
  ].freeze

  VALUES = (WITH_YOUTH_COURT_OPTIONS + WITHOUT_YOUTH_COURT_OPTIONS).uniq.freeze
end
