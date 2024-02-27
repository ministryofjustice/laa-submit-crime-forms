require_relative 'lib/laa_multi_step_forms/version'

Gem::Specification.new do |spec|
  spec.name        = 'laa_multi_step_forms'
  spec.version     = LaaMultiStepForms::VERSION
  spec.authors     = ['David Henry']
  spec.email       = ['david.henry@digital.justice.gov.uk']
  spec.summary     = 'Multipart forms for LAA'
  spec.description = 'Base implementation of multipart forms for LAA'
  spec.required_ruby_version = '>= 3.3'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = ''
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'rails', '>= 7.0.4.3'

  spec.add_dependency 'govuk-components', '>= 5.0.0'
  spec.add_dependency 'govuk_design_system_formbuilder', '>= 4.0', '< 5.3'
  spec.add_dependency 'hmcts_common_platform'

  # Authentication
  spec.add_dependency 'devise', '~> 4.8'
  spec.add_dependency 'omniauth-rails_csrf_protection', '~> 1.0.1'
  spec.add_dependency 'omniauth-saml', '~> 2.1.0'

  # validations
  spec.add_dependency 'uk_postcode'

  # Exceptions notifications
  spec.add_dependency 'sentry-rails'
  spec.add_dependency 'sentry-ruby'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
