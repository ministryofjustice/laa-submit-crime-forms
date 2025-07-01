module LaaMultiStepForms
  class ApplicationController < ActionController::Base
    include ErrorHandling
    helper StepsHelper
    include ApplicationHelper

    prepend_before_action :authenticate_provider!
    before_action :set_current_user

    private

    def set_current_user
      return unless provider_signed_in?

      GlobalContext.current_user = current_provider
    end
  end
end
