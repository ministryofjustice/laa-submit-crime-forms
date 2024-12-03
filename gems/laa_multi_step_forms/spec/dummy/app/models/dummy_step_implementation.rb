# used so that we can easily stub this method into the controller
class DummyStepImplementation
  class << self
    def current_application
      # This is a placeholder to help with stubbing for tests
    end

    def form_class
      # This is a placeholder to help with stubbing for tests
    end

    def options
      # This is a placeholder to help with stubbing for tests
    end

    def decision_tree_class
      # This is a placeholder to help with stubbing for tests
    end

    def do_not_add_to_viewed_steps
      # This is a placeholder to help with stubbing for tests
      false
    end
  end
end
