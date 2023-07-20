module Tasks
  class SolicitorDeclaration < Generic
    PREVIOUS_TASK = CheckAnswers
    FORM = Steps::SolicitorDeclarationForm

    def path
      edit_steps_solicitor_declaration_path(application)
    end
  end
end
