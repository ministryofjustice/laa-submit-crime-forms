module PriorAuthority
  class UfnFormsController < PriorAuthority::BaseController
    before_action :instantiate_model
    def update
      if @model.extended_update(allowed_params)
        redirect_to prior_authority_application_path(@model)
      else
        render :show
      end
    end

    private

    def instantiate_model
      @model = current_provider.prior_authority_applications
                               .find(params[:application_id])
                               .becomes(PriorAuthority::UfnForm)
    end

    def allowed_params
      params.require(:prior_authority_ufn_form).permit(:ufn)
    end
  end
end
