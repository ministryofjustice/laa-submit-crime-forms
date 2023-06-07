class WorkItems < ValueObject
  VALUES = [
    PREPARATION = new(:preparation),
    ADVOCACY = new(:advocacy),
    ATTENDANCE_WITH_COUNSEL = new(:attendance_with_counsel),
    ATTENDANCE_WITHOUT_COUNSEL = new(:attendance_without_counsel),
    TRAVEL = new(:travel),
    WAITING = new(:waiting),
  ].freeze
end
