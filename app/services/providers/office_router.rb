module Providers
  class OfficeRouter
    include Rails.application.routes.url_helpers

    attr_reader :provider

    def initialize(provider)
      @provider = provider
    end

    def self.call(provider)
      new(provider).path
    end

    def path
      claims_path

      # TODO: add this back in once the office selection is re-enabled
      # if provider.selected_office_code.blank?
      #   edit_steps_provider_select_office_path
      # elsif provider.multiple_offices?
      #   edit_steps_provider_confirm_office_path
      # else
      #   crime_applications_path
      # end
    end
  end
end
