require 'rails_helper'

RSpec.describe Provider, type: :model do
  subject { described_class.new(attributes) }

  let(:attributes) do
    {
      uid: 'test-user',
      email: 'provider@example.com',
      office_codes: office_codes,
    }
  end

  let(:office_codes) { %w[A1 B2 C3] }

  describe '#display_name' do
    it { expect(subject.display_name).to eq('provider@example.com') }
  end

  describe '#multiple_offices?' do
    context 'provider has more than 1 office account' do
      it { expect(subject.multiple_offices?).to be(true) }
    end

    context 'provider has only 1 office account' do
      let(:office_codes) { %w[A1] }

      it { expect(subject.multiple_offices?).to be(false) }
    end
  end

  describe '#from_omniauth' do
    let(:info) { double('info', email: 'test@test.com', description: 'desc', roles: 'a,b') }
    let(:auth) { double('auth', provider: 'govuk', uid: SecureRandom.uuid, info: info) }

    context 'new user' do
      context 'when multiple office codes' do
        let(:office_codes) { %w[A1 A2] }

        it 'creates a new user record' do
          expect { described_class.from_omniauth(auth, office_codes) }.to change(described_class, :count).by(1)
        end
      end
    end
  end
end
