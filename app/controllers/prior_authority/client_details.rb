module PriorAuthoritySteps
  class ClientDetailsController < Steps::BaseStepController
    def edit
      @form_object = ClientDetailsForm.build(
        current_prior_auth_application
      )
    end

    def update
      update_and_advance(ClientDetailsForm, as: :client_details)
    end

    private

    def decision_tree_class
      Decisions::DecisionTree
    end
  end
end
