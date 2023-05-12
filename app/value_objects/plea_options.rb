class PleaOptions < ValueObject
  GUILTY_OPTIONS = [
    GUILTY = new(:guilty),
    BREACH = new(:uncontested_breach),
    DISCONTINUANCE = new(:discontinuance),
    BIND_OVER = new(:bind_over),
    DEFERRED_SENTENCE = new(:deferred_sentence),
    CHANGE_SOLICITOR = new(:change_solicitor),
    ARREST_WARRENT = new(:arrest_warrent),
  ].freeze

  NOT_GUILTY_OPTIONS = [
    NOT_GUILTY = new(:not_guilty),
    CRACKED_TRIAL = new(:cracked_trial),
    CONTESTED = new(:contested),
    DISCONTINUANCE = new(:deferred_sentence),
    MIXED = new(:mixed),
  ].freeze

  VALUES = GUILTY_OPTIONS + NOT_GUILTY_OPTIONS

  HAS_DATE_FIELD = [
    ARREST_WARRENT,
    CRACKED_TRIAL,
  ].freeze

  def requires_date_field?
    HAS_DATE_FIELD.include?(self)
  end
end
