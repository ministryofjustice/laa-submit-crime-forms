class CaseOutcome < ValueObject
  CATEGORY_1_OUTCOMES = [
    GUILTY              = new(:guilty),
    DISCONTINUANCE      = new(:discontinuance),
    ARREST_WARRANT      = new(:arrest_warrant),
    CHANGE_SOLICITOR    = new(:change_solicitor),
    OTHER               = new(:other)
  ].freeze

  CATEGORY_2_OUTCOMES = [
    CONTESTED_TRIAL     = new(:contested_trial),
    DISCONTINUANCE,
    OTHER
  ].freeze

  VALUES = (CATEGORY_1_OUTCOMES + CATEGORY_2_OUTCOMES).uniq.freeze

  HAS_DATE_FIELD = [
    ARREST_WARRANT,
    CHANGE_SOLICITOR
  ].freeze

  def requires_date_field?
    HAS_DATE_FIELD.include?(self)
  end
end
