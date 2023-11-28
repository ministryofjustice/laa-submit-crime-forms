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
      if provider.selected_office_code.blank?
        edit_steps_office_select_path
      elsif provider.multiple_offices?
        edit_steps_office_confirm_path
      else
        applications_path
      end
    end
  end
end
