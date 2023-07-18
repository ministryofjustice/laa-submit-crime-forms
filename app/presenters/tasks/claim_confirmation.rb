module Tasks
  class ClaimConfirmation < Generic
    PREVIOUS_TASK = SolicitorDeclaration

    def path
      steps_claim_confirmation_path(application)
    end
  end
end
