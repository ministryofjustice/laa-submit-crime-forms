module PriorAuthority
  module Steps
    class AuthorityValueController < BaseController
      def edit
        @form_object = AuthorityValueForm.build(
          current_application
        )
      end

      def update
        @form_object = current_application.becomes(AuthorityValueForm)
        @form_object.assign_attributes(allowed_params)

        if @form_object.valid?
          if @form_object.authority_value
            redirect_to offboard_prior_authority_application_path(current_application)
          else
            update_and_advance(AuthorityValueForm, as: :authority_value)
          end
        else
          render :edit
        end
      end

      def allowed_params
        params.require(:prior_authority_steps_authority_value_form).permit(:authority_value)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end
    end
  end
end
