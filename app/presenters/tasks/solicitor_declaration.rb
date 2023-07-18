module Tasks
  class SolicitorDeclaration < Generic
    PREVIOUS_TASK = SupportingEvidence
    FORM = Steps::SolicitorDeclarationForm

    def path
      edit_steps_solicitor_declaration_path(application)
    end
  end
end
