module Tasks
  class OtherInfo < Generic
    PREVIOUS_TASK = LettersCalls
    FORM = Steps::OtherInfoForm

    def path
      edit_steps_other_info_path(application)
    end

    def completed?
      Steps::OtherInfoForm.build(application).valid?
    end
  end
end
