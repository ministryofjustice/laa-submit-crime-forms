require 'omniauth'
require Rails.root.join('app/lib/laa_portal/saml_strategy')

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.logger = Rails.logger
    config.logger.level = Logger::WARN if Rails.env.test?
    config.add_mock(:saml, LaaPortal::SamlStrategy.mock_auth)
    config.test_mode = Rails.env.test? || FeatureFlags::FeatureFlag.active?(:omniauth_test_mode)

    # This allow us to overwrite the fake auth settings and pretend to be different users for testing
    # ideally only the following keys should be set:
    # * uid => "test-user"
    # * info[name] => "Example User"
    # * info[email] => "provider@example.com"
    # * info[office_codes] => ["1A123B", "2A555X"]
    if ENV.fetch('OMNIAUTH_TEST_MODE', 'false').inquiry.true?
      config.before_callback_phase do |env|
        env['omniauth.auth'].merge!(
          Rack::Utils.parse_nested_query(env['QUERY_STRING'])
        )
      end
    end
  end
end
