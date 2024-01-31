module PriorAuthority
  class ServiceTypesController < ApplicationController
    skip_before_action :authenticate_provider!

    def index
      respond_to do |format|
        format.json { render json: service_types }
      end

      expires_in 60.minutes
    end

    private

    def service_types
      QuoteServices.values.map { |value| {  value: value.value, en: value.translated } }
    end
  end
end
