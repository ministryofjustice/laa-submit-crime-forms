require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Crm7restbackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.x.gatekeeper= config_for(
      :gatekeeper, env: ENV.fetch('ENV_NAME', 'localhost')
    )

    config.active_job.queue_adapter = :sidekiq

    config.x.contact.case_enquiries_tel = '0300 200 2020'
    config.x.contact.support_email = 'CRM457@digital.justice.gov.uk'
  end
end
