module PriorAuthority
  class AuthorityValueFormsController < PriorAuthority::BaseController
    before_action :instantiate_model
    def update
      @model.assign_attributes(allowed_params)
      if @model.valid?
        if @model.less_than_five_hundred
          redirect_to offboard_prior_authority_application_path(@model)
        else
          redirect_to prior_authority_application_ufn_form_path(@model)
        end
      else
        render :show
      end
    end

    private

    def instantiate_model
      @model = current_provider.prior_authority_applications
                               .find(params[:application_id])
                               .becomes(PriorAuthority::AuthorityValueForm)
    end

    def allowed_params
      params.require(:prior_authority_authority_value_form).permit(:less_than_five_hundred)
    end
  end
end
