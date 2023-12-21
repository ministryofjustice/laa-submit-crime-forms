# frozen_string_literal: true

RSpec.describe AppStoreTokenProvider do
  subject(:client) { described_class.new }

  it { is_expected.to respond_to :oauth_client, :access_token, :bearer_token }

  describe '#oauth_client' do
    subject { described_class.new.oauth_client }

    it { is_expected.to be_an OAuth2::Client }
    it { is_expected.to respond_to :client_credentials }
  end

  describe '#access_token' do
    subject(:access_token) { client.access_token }

    before do
      stub_request(:post, %r{https.*/oauth2/v2.0/token})
        .to_return(
          status: 200,
          body: '{"access_token":"test-bearer-token","token_type":"Bearer","expires_in":7200,"created_at":1582809000}',
          headers: { 'Content-Type' => 'application/json; charset=utf-8' }
        )
    end

    it { is_expected.to be_an OAuth2::AccessToken }
    it { is_expected.to respond_to :token }
    it { expect(access_token.token).to eql 'test-bearer-token' }

    context 'when token nil? or expired?' do
      let(:test_client) { client }

      before do
        allow(test_client).to receive(:new_access_token)
      end

      it 'retrieves new access_token' do
        access_token
        expect(test_client).to have_received(:new_access_token)
      end
    end
  end

  describe '#bearer_token' do
    subject(:bearer_token) { client.bearer_token }

    it { is_expected.to be_a String }
    it { is_expected.to eql 'fake-laa-crime-application-store-bearer-token' }
  end
end
