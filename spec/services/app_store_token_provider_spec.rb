# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AppStoreTokenProvider do
  subject(:client) { described_class.instance }

  it { is_expected.to respond_to :oauth_client, :access_token, :bearer_token }

  describe '#oauth_client', :stub_oauth_token do
    subject { described_class.instance.oauth_client }

    it { is_expected.to be_an OAuth2::Client }
    it { is_expected.to respond_to :client_credentials }
  end

  describe '#access_token', :stub_expired_oauth_token do
    subject(:access_token) { client.access_token }

    it { is_expected.to be_an OAuth2::AccessToken }
    it { is_expected.to respond_to :token }
    it { expect(access_token.token).to eql 'test-bearer-token' }

    context 'when token nil? or expired?' do
      let(:test_client) { client }

      before do
        allow(test_client).to receive(:new_access_token)
        access_token
      end

      it 'retrieves new access_token' do
        access_token
        expect(test_client).to have_received(:new_access_token)
      end
    end
  end

  describe '#bearer_token', :stub_oauth_token do
    subject(:bearer_token) { client.bearer_token }

    it { is_expected.to be_a String }
    it { is_expected.to eql 'test-bearer-token' }
  end
end
