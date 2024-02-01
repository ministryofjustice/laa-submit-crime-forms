module Nsm
  class OffencesController < ApplicationController
    skip_before_action :authenticate_provider!
    skip_before_action :can_access_service

    def index
      respond_to do |format|
        format.json { render json: offences }
      end

      expires_in 60.minutes
    end

    private

    def offences
      MainOffence.all.map(&:as_json)
    end
  end
end
