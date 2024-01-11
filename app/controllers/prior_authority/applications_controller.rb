module PriorAuthority
  class ApplicationsController < PriorAuthority::BaseController
    def index
      @model = current_provider.prior_authority_applications.draft
    end

    def show
      @model = current_provider.prior_authority_applications.find(params[:id])
    end

    def create
      application = current_provider.prior_authority_applications.create!
      redirect_to prior_authority_application_prison_law_form_path(application)
    end

    def confirm_delete
      @model = current_provider.prior_authority_applications.find(params[:id])
    end

    def destroy
      @model = current_provider.prior_authority_applications.find(params[:id])
      @model.destroy
      redirect_to prior_authority_applications_path
    end
  end
end
