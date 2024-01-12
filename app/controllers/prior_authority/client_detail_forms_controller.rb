module PriorAuthority
  class ClientDetailFormsController < PriorAuthority::BaseController
    before_action :instantiate_model

    def update
      if @model.extended_update(allowed_params, skip_validation: params[:commit_draft])
        redirect_to prior_authority_application_path(@model)
      else
        render :show
      end
    end

    private

    def instantiate_model
      @model = current_provider.prior_authority_applications
                               .find(params[:application_id])
                               .becomes(PriorAuthority::ClientDetailForm)
    end

    def allowed_params
      params.require(:prior_authority_client_detail_form)
            .permit(:client_first_name, :client_last_name, :firm_name, :client_date_of_birth)
    end
  end
end
