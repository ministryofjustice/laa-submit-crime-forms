require 'rails_helper'

RSpec.describe UserAuthenticate do
  describe '.authenticate' do
    subject(:authenticate) { described_class.new(auth_hash).authenticate }

    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        {
          uid: SecureRandom.uuid,
        info: {
          email: 'test@example.com',
        }
        }
      )
    end

    let(:user) { nil }

    before { user }

    context 'when user does not exist in database' do
      it { is_expected.to be_nil }
    end

    context 'when the user is active' do
      let(:user) { create(:caseworker, auth_uid: auth_hash.uid) }

      it 'returns the user' do
        expect(authenticate).to eq user
      end
    end

    context 'when the user is deactivated' do
      let(:user) { create(:caseworker, :deactivated, auth_uid: auth_hash.uid) }

      it 'returns nil' do
        expect(authenticate).to be_nil
      end
    end
  end
end
