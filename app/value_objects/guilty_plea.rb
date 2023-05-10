class GuiltyPlea < ValueObject
  VALUES = [
    BREACH = new(:uncontested_breach),
    DISCONTINUANCE = new(:discontinuance),
    BIND_OVER = new(:bind_over),
    DEFERRED_SENTENCE = new(:deferred_sentence),
    CHANGE_SOLICITOR = new(:change_solicitor),
    ARREST_WARRENT = new:(arrest_warrent),
  ].freeze

  def has_date_field?
    self == ARREST_WARRENT
  end
end

# Uncontested breach
# Discontinuance or withdrawal
# Bind over
# Deferred sentence hearing
# Change of solicitor
# Warrent of arrest
