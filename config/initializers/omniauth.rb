require 'omniauth'
require Rails.root.join('app/lib/laa_portal/saml_strategy')

Rails.application.config.middleware.use OmniAuth::Builder do
  configure do |config|
    config.logger = Rails.logger
    config.logger.level = Logger::WARN if Rails.env.test?
    config.add_mock(:saml, LaaPortal::SamlStrategy.mock_auth)
    if test_feature_enabled?
      config.test_mode = true

      # This allow us to overwrite the fake auth settings and pretend to be different users for testing
      # ideally only the following keys should be set:
      # * uid => "test-user"
      # * info[name] => "Example User"
      # * info[email] => "provider@example.com"
      # * info[office_codes] => ["1A123B", "2A555X"]
      if FeatureFlags::FeatureFlag.active?(:omniauth_test_mode)
        config.before_callback_phase do |env|
          env['omniauth.auth'].merge!(
            Rack::Utils.parse_nested_query(env['QUERY_STRING'])
          )
        end
      end
    else
      config.test_mode = Rails.env.test?
    end
  end
end

private

def test_feature_enabled?
  if database_connected?
    FeatureFlags::FeatureFlag.active?(:omniauth_test_mode)
  end
rescue ActiveRecord::StatementInvalid
 false
end

def database_connected?
  ActiveRecord::Base.connection
rescue ActiveRecord::ConnectionNotEstablished
  false
else
  true
end
