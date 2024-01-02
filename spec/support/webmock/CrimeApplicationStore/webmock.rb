# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each, :stub_oauth_token) do
    stub_request(:post, %r{https.*/oauth2/v2.0/token})
      .to_return(
        status: 200,
        body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":3600,"created_at":1582809000}',
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
  end

  config.before(:each, :stub_expired_oauth_token) do
    stub_request(:post, %r{https.*/oauth2/v2.0/token})
      .to_return(
        status: 200,
        body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":0,"created_at":1582809000}',
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
  end
end
