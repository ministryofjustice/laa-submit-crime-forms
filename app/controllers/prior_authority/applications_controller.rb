module PriorAuthority
  class ApplicationsController < ApplicationController
    before_action :authenticate_provider!
    layout 'prior_authority'

    def index
      @model = current_provider.prior_authority_applications.draft
    end

    def create
      initialize_application do |paa|
        redirect_to edit_prior_authority_steps_prison_law_path(paa)
      end
    end

    def confirm_delete
      @model = current_provider.prior_authority_applications.find(params[:id])
    end

    def destroy
      @model = current_provider.prior_authority_applications.find(params[:id])
      @model.destroy
      redirect_to prior_authority_applications_path
    end

    def offboard
      @model = current_provider.prior_authority_applications.find(params[:id])
    end

    private

    def initialize_application(attributes = {}, &block)
      attributes[:office_code] = current_office_code
      current_provider.prior_authority_applications.create!(attributes).tap(&block)
    end

    def service
      Providers::Gatekeeper::PAA
    end
  end
end
