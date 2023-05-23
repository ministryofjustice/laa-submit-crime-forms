module Steps
  class DefendantDetailsController < Steps::BaseStepController
    def edit
      @form_object = DefendantsDetailsForm.build(
        current_application
      )
    end

    def update
      update_and_advance(DefendantsDetailsForm, as: step_name, flash: flash_msg)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def step_name
      if params.key?('add_defendant')
        :add_defendant
      elsif params.to_s.include?('"_destroy"=>"1"')
        :delete_defendant
      else
        :defendant_details
      end
    end

    def flash_msg
      { success: t('.edit.deleted_flash') } if step_name.eql?(:delete_defendant)
    end

    def additional_permitted_params
      [defendants_attributes: Steps::DefendantDetailsForm.attribute_names]
    end
  end
end
