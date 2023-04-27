require 'devise'
require 'omniauth-saml'
require 'omniauth/rails_csrf_protection'
require 'govuk_design_system_formbuilder'

module LaaMultiStepForms
  class Engine < ::Rails::Engine
    # isolate_namespace LaaMultiStepForms
    engine_name 'laa_msf'
  end
end
