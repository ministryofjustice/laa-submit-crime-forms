# skip autoloading on this file as it has a non standard naming pattern
SUBDOMAINS = %w[
  app/lib/govuk_design_system_formbuilder
].freeze

Rails.autoloaders.each do |autoloader|
  SUBDOMAINS.each do |sub|
    autoloader.ignore(LaaMultiStepForms::Engine.root.join(sub))
  end
end
