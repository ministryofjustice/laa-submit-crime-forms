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

      context 'when single office code' do
        let(:office_codes) { %w[A1] }

        it 'creates a new user record' do
          expect { described_class.from_omniauth(auth, office_codes) }.to change(described_class, :count).by(1)
        end
      end

      context 'when no office codes provided' do
        let(:office_codes) { [] }

        it 'creates a new user record with empty office codes' do
          expect { described_class.from_omniauth(auth, office_codes) }.to change(described_class, :count).by(1)
          user = described_class.last
          expect(user.office_codes).to eq([])
        end
      end
    end

    context 'migration scenarios' do
      let!(:existing_user) do
        described_class.create!(
          email: 'test@test.com',
          auth_provider: 'old_saml',
          uid: 'old-uid-123',
          office_codes: %w[A1 B2],
          description: 'old desc'
        )
      end

      context 'user changed email but kept same provider/uid temporarily' do
        let(:info) { double('info', email: 'newemail@test.com', description: 'desc', roles: 'a,b') }
        let(:auth) { double('auth', provider: 'old_saml', uid: 'old-uid-123', info: info) }

        it 'finds by auth info and updates email' do
          expect { described_class.from_omniauth(auth, office_codes) }
            .not_to change(described_class, :count)
          existing_user.reload
          expect(existing_user.email).to eq('newemail@test.com')
          expect(existing_user.office_codes).to eq(office_codes)
        end
      end

      context 'existing user with same provider/uid gets new office codes' do
        let(:auth) { double('auth', provider: 'old_saml', uid: 'old-uid-123', info: info) }
        let(:office_codes) { %w[X1 Y2 Z3] }

        it 'updates office codes for existing user' do
          expect { described_class.from_omniauth(auth, office_codes) }
            .not_to change(described_class, :count)
          existing_user.reload
          expect(existing_user.office_codes).to eq(%w[X1 Y2 Z3])
          expect(existing_user.email).to eq('test@test.com')
        end
      end

      context 'existing user loses office codes' do
        let(:auth) { double('auth', provider: 'old_saml', uid: 'old-uid-123', info: info) }
        let(:office_codes) { [] }

        it 'removes office codes for existing user' do
          expect { described_class.from_omniauth(auth, office_codes) }
            .not_to change(described_class, :count)
          existing_user.reload
          expect(existing_user.office_codes).to eq([])
        end
      end

      context 'existing user has unsorted office codes' do
        let(:auth) { double('auth', provider: 'old_saml', uid: 'old-uid-123', info: info) }
        let(:office_codes) { %w[C3 B2 A1] }

        it 'removes office codes for existing user' do
          expect { described_class.from_omniauth(auth, office_codes) }
            .not_to change(described_class, :count)
          existing_user.reload
          expect(existing_user.office_codes).to eq(%w[A1 B2 C3])
        end
      end
    end
  end
end
