require_relative 'lib/laa_multi_step_forms/version'

Gem::Specification.new do |spec|
  spec.name        = 'laa_multi_step_forms'
  spec.version     = LaaMultiStepForms::VERSION
  spec.authors     = ['David Henry']
  spec.email       = ['david.henry@digital.justice.gov.uk']
  # spec.homepage    = "TODO"
  spec.summary     = 'Multipart forms for LAA'
  spec.description = 'Base implementation of multipart forms for LAA'
  spec.required_ruby_version = '>= 3.2'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = ''

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'govuk_design_system_formbuilder', '~> 3.3.0'
  spec.add_dependency 'rails', '>= 7.0.4.3'

  # Authentication
  spec.add_dependency 'devise', '~> 4.8'
  spec.add_dependency 'omniauth-rails_csrf_protection', '~> 1.0.1'
  spec.add_dependency 'omniauth-saml', '~> 2.1.0'

  spec.add_development_dependency 'rspec-rails', '~> 6.0.1'
  spec.add_development_dependency 'rubocop', '~> 1.49'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
