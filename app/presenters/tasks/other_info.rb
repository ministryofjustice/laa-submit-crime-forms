module Tasks
  class OtherInfo < Generic
    PREVIOUS_TASK = LettersCalls
    FORM = Steps::OtherInfoForm

    def can_start?
      application.navigation_stack.include?(steps_cost_summary_path(application))
    end

    def path
      edit_steps_other_info_path(application)
    end
  end
end
