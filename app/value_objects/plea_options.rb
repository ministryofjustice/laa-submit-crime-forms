class PleaOptions < ValueObject
  GUILTY_OPTIONS = [
    GUILTY = new(:guilty),
    BREACH = new(:uncontested_breach),
    DISCONTINUANCE_CAT1 = new(:discontinuance_cat1),
    BIND_OVER = new(:bind_over),
    DEFERRED_SENTENCE = new(:deferred_sentence),
    CHANGE_SOLICITOR = new(:change_solicitor),
    ARREST_WARRANT = new(:arrest_warrant),
  ].freeze

  NOT_GUILTY_OPTIONS = [
    NOT_GUILTY = new(:not_guilty),
    CRACKED_TRIAL = new(:cracked_trial),
    CONTESTED = new(:contested),
    DISCONTINUANCE_CAT2 = new(:discontinuance_cat2),
    MIXED = new(:mixed),
  ].freeze

  VALUES = GUILTY_OPTIONS + NOT_GUILTY_OPTIONS

  HAS_DATE_FIELD = [
    ARREST_WARRANT,
    CRACKED_TRIAL,
  ].freeze

  def requires_date_field?
    HAS_DATE_FIELD.include?(self)
  end

  def category
    return :guilty_pleas if GUILTY_OPTIONS.include?(self)

    return :not_guilty_pleas if NOT_GUILTY_OPTIONS.include?(self)

    nil
  end
end
