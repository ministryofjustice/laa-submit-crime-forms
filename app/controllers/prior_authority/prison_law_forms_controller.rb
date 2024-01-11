module PriorAuthority
  class PrisonLawFormsController < PriorAuthority::BaseController
    before_action :instantiate_model
    def update
      if @model.update(allowed_params)
        redirect_to prior_authority_application_authority_value_form_path(@model)
      else
        render :show
      end
    end

    private

    def instantiate_model
      @model = current_provider.prior_authority_applications
                               .find(params[:application_id])
                               .becomes(PriorAuthority::PrisonLawForm)
    end

    def allowed_params
      params.require(:prior_authority_prison_law_form).permit(:prison_law)
    end
  end
end
