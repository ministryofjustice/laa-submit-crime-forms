class WorkTypes < ValueObject
  def initialize(raw_value, &block)
    @block = block
    super(raw_value)
  end

  def display?(application)
    return true if @block.nil?

    @block.call(application, :provider)
  end

  def display_to_caseworker?(application)
    return true if @block.nil?

    @block.call(application, :caseworker)
  end

  VALUES = [
    ATTENDANCE_WITH_COUNSEL = new(:attendance_with_counsel) do |application, user_type|
      user_type == :caseworker || application.assigned_counsel == YesNoAnswer::YES.to_s
    end,
    ATTENDANCE_WITHOUT_COUNSEL = new(:attendance_without_counsel),
    PREPARATION = new(:preparation),
    ADVOCACY = new(:advocacy),
    TRAVEL = new(:travel) { |claim, _| claim.prog_stage_reached? },
    WAITING = new(:waiting) { |claim, _| claim.prog_stage_reached? },
  ].freeze
end
