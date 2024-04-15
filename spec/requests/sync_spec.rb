require 'rails_helper'

RSpec.describe 'Syncs' do
  describe 'GET /sync' do
    let(:job) { instance_double(PullUpdates, perform: true) }

    before { allow(PullUpdates).to receive(:new).and_return(job) }

    it 'triggers a sync job' do
      get '/sync'

      expect(response).to have_http_status(:ok)
      expect(job).to have_received(:perform)
    end
  end

  describe 'POST /app_store_webhook' do
    context 'when no auth token is provided' do
      it 'rejects all requests' do
        post '/app_store_webhook'
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when an auth token is provided' do
      before do
        AppStoreTokenAuthenticator.instance_variable_set(:@jwks, nil)
        stub_request(:get, 'https://login.microsoftonline.com/123/.well-known/openid-configuration')
          .to_return(status: 200,
                     body: { jwks_uri: 'https://example.com/jwks' }.to_json,
                     headers: { 'Content-type' => 'application/json' })
        stub_request(:get, 'https://example.com/jwks')
          .to_return(status: 200,
                     body: { keys: 'keys' }.to_json,
                     headers: { 'Content-type' => 'application/json' })
      end

      context 'when the token is invalid' do
        it 'rejects the request' do
          post '/app_store_webhook', headers: { 'Authorization' => 'Bearer ABC' }
          expect(response).to have_http_status(:unauthorized)
          expect(response).to have_http_status :unauthorized
        end
      end

      context 'when the token is valid' do
        let(:jwks) { instance_double(JWT::JWK::Set) }
        let(:decoded) do
          [{ 'aud' => 'UNDEFINED_APP_STORE_CLIENT_ID',
             'iss' => 'https://login.microsoftonline.com/123/v2.0',
             'exp' => 1.hour.from_now.to_i }]
        end
        let(:client) { instance_double(AppStoreClient) }
        let(:record) { :record }

        before do
          allow(JWT::JWK::Set).to receive(:new).with('keys').and_return(jwks)
          allow(JWT).to receive(:decode).with('ABC', nil, true, { algorithms: 'RS256', jwks: jwks }).and_return(decoded)

          allow(AppStoreClient).to receive(:new).and_return(client)
          allow(client).to receive(:get).and_return(record)
          allow(AppStoreUpdateProcessor).to receive(:call)
        end

        it 'triggers a sync' do
          post '/app_store_webhook', params: { submission_id: '123' }, headers: { 'Authorization' => 'Bearer ABC' }
          expect(response).to have_http_status(:ok)
          expect(client).to have_received(:get).with('123')
          expect(AppStoreUpdateProcessor).to have_received(:call).with(record, is_full: true)
        end
      end
    end
  end
end
