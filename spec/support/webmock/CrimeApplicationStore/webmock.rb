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

  config.before(:each, :stub_app_store_search) do
    stub_request(:post, 'https://app-store.example.com/v1/submissions/searches').to_return(
      status: 201,
      body: { metadata: { total_results: 0 }, raw_data: [] }.to_json
    )
  end
end
