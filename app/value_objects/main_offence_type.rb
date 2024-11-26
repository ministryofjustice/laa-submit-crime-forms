class MainOffenceType < ValueObject
  VALUES = [
    SUMMARY_ONLY = new(:summary_only),
    EITHER_WAY = new(:either_way),
    INDICTABLE_ONLY = new(:indictable_only),
    PRESCRIBED_PROCEEDINGS = new(:prescribed_proceedings),
  ].freeze
end
