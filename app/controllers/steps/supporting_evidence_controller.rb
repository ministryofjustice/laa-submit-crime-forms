# frozen_string_literal: true

module Steps
  class SupportingEvidenceController < Steps::BaseStepController
    skip_before_action :verify_authenticity_token
    def edit
      # @form_object = SupportingEvidenceForm.build(current_application)
    end

    def create
      logger.info "I made it maa"
    end

    def update
      update_and_advance(SupportingEvidenceForm)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def additional_permitted_params
      [:send_by_post]
    end
  end
end

