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

    private

    def initialize_application(attributes = {}, &block)
      attributes[:office_code] = current_office_code
      attributes[:laa_reference] = generate_laa_reference

      current_provider.prior_authority_applications.create!(attributes).tap(&block)
      # PriorAuthorityApplication.create!(attributes).tap(&block)
    end

    def current_office_code
      @current_office_code ||= current_provider&.selected_office_code
    end

    def generate_laa_reference
      loop do
        random_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
        break random_reference unless Claim.exists?(laa_reference: random_reference)
      end
    end
  end
end
