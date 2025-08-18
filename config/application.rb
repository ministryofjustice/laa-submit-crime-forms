require_relative 'boot'

require 'rails/all'
require 'action_mailer/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Crm7restbackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.assets.paths << Rails.root.join('node_modules/govuk-frontend/dist/govuk/assets')

    config.x.office_code_overrides = config_for(:office_code_overrides, env: ENV.fetch('ENV', 'localhost'))

    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = :mailers

    config.active_support.to_time_preserves_timezone = :zone

    config.x.application.name = 'Claim a non-standard magistrates\' court payment'

    config.x.contact.case_enquiries_tel = '0300 200 2020'
    config.x.contact.support_email = 'magsbilling@justice.gov.uk'
    config.x.contact.technical_support_email = 'nscc@justice.gov.uk'
    config.x.contact.nsm_rfi_email = 'CRM7fi.request@justice.gov.uk'
    config.x.analytics.cookies_consent_name = 'cookies_preferences_set'
    config.x.analytics.cookies_consent_expiration = 1.year
    config.x.analytics.analytics_consent_name = 'analytics_preferences_set'
    config.x.analytics.analytics_consent_expiration = 1.year

    config.x.nsm.feedback_url = 'https://www.smartsurvey.co.uk/s/D07AXK/'
    config.x.prior_authority.feedback_url = 'https://www.smartsurvey.co.uk/s/JCMEZ8/'
    config.x.research_url = 'https://forms.office.com/Pages/ResponsePage.aspx?id=KEeHxuZx_kGp4S6MNndq2BpeqOUlDIpGmeYA_28YLbNUMjJaNVJIMzdQMkRLRUFEM05VVEFNSlpCQS4u'

    config.x.redis_url = if ENV['REDIS_HOST'].present? && ENV['REDIS_PASSWORD'].present?
                           protocol = ENV.fetch('REDIS_PROTOCOL', 'rediss')
                           password = ENV.fetch('REDIS_PASSWORD')
                           host = ENV.fetch('REDIS_HOST')
                           "#{protocol}://:#{password}@#{host}:6379"
                         end

    config.x.notification_banner = config_for(:notification_banner, env: ENV.fetch('ENV', 'localhost'))

    # The maximum period of inactivity before a user is
    # automatically signed out.
    config.x.auth.timeout_in = 1.hour
  end
end
