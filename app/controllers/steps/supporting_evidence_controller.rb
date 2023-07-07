# frozen_string_literal: true

module Steps
  class SupportingEvidenceController < Steps::BaseStepController
    def edit; end

    def update; end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end
  end
end

