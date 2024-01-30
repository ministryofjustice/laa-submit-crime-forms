require 'omniauth'
require Rails.root.join('app/lib/laa_portal/saml_strategy')

# This is used to avoid the default auth hash being cached between test cases
module AuthMemory
  def self.put(val)
    @val = val
  end

  def self.get
    @val
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.logger = Rails.logger
    config.logger.level = Logger::WARN if Rails.env.test?
    config.add_mock(:saml, LaaPortal::SamlStrategy.mock_auth)
    config.test_mode = Rails.env.test? || FeatureFlags.omniauth_test_mode.enabled?

    # This allow us to overwrite the fake auth settings and pretend to be different users for testing
    # ideally only the following keys should be set:
    # * uid => "test-user"
    # * info[name] => "Example User"
    # * info[email] => "provider@example.com"
    # * info[office_codes] => ["1A123B", "2A555X"]
    if FeatureFlags.omniauth_test_mode.enabled?
      config.before_callback_phase do |env|
        AuthMemory.put(env['omniauth.auth'].dup)
        env['omniauth.auth'] = AuthMemory.get.merge(
          Rack::Utils.parse_nested_query(env['QUERY_STRING'])
        )
      end
    end
  end
end
