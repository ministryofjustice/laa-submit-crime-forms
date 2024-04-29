module Nsm
  class ClaimsController < ApplicationController
    layout 'nsm'

    def index
      filtered_claims = Claim.for(current_provider).where.not(ufn: nil).order('updated_at DESC')
      @pagy, @claims = pagy(filtered_claims)
    end

    def create
      initialize_application do |claim|
        redirect_to edit_nsm_steps_claim_type_path(claim.id)
      end
    end

    private

    def initialize_application(attributes = {}, &block)
      attributes.merge!(
        office_code: (current_provider.office_codes.first if current_provider.office_codes.count == 1),
        submitter: current_provider,
        laa_reference: generate_laa_reference
      )
      Claim.create!(attributes).tap(&block)
    end

    def generate_laa_reference
      loop do
        random_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
        break random_reference unless Claim.exists?(laa_reference: random_reference)
      end
    end

    def service
      Providers::Gatekeeper::NSM
    end
  end
end
