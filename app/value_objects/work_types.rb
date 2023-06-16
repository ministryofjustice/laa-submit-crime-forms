class WorkTypes < ValueObject
  def initialize(raw_value, &block)
    @block = block
    super(raw_value)
  end

  def display?(application)
    return true if @block.nil?

    @block.call(application)
  end

  VALUES = [
    ATTENDANCE_WITH_COUNSEL = new(:attendance_with_counsel) do |application|
      application.assigned_counsel == YesNoAnswer::YES.to_s
    end,
    ATTENDANCE_WITHOUT_COUNSEL = new(:attendance_without_counsel),
    PREPARATION = new(:preparation),
    ADVOCACY = new(:advocacy),
    TRAVEL = new(:travel) do |application|
      application.in_area == YesNoAnswer::NO.to_s
    end,
    WAITING = new(:waiting) do |application|
      application.in_area == YesNoAnswer::NO.to_s
    end,
  ].freeze
end
