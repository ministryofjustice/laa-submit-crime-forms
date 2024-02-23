module Decisions
  class Rule
    attr_reader :destinations

    def when(condition)
      @condition = condition
      self
    end

    def goto(**destination, &block)
      @destinations ||= []
      @destinations << [@condition, block || destination]
      @condition = nil
      self
    end
  end
end
