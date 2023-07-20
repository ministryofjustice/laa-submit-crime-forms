module Decisions
  class Rule
    attr_reader :destinations

    def when(condition)
      @condition = condition
      self
    end

    def goto(**destination)
      @destinations ||= []
      @destinations << [@condition, destination]
      @condition = nil
      self
    end
  end
end
