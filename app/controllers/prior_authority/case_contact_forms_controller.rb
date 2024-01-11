module PriorAuthority
  class CaseContactFormsController < PriorAuthority::BaseController
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
                               .becomes(PriorAuthority::CaseContactForm)
    end

    def allowed_params
      params.require(:prior_authority_case_contact_form)
            .permit(:contact_name, :contact_email, :firm_name, :firm_account_number)
    end
  end
end
