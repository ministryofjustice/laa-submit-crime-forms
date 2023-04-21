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
    let(:info) { double('info', email: 'test@test.com', description: 'desc', roles: 'a,b', office_codes: office_codes) }
    let(:auth) { double('auth', provider: 'govuk', uid: SecureRandom.uuid, info: info) }

    context 'new user' do
      context 'when multiple office codes' do
        let(:office_codes) { %w[A1 A2] }

        it 'creates a new user record' do
          expect { described_class.from_omniauth(auth) }.to change(described_class, :count).by(1)
        end

        it 'does not set the selected_office_code' do
          described_class.from_omniauth(auth)
          expect(described_class.last.selected_office_code).to be_nil
        end
      end

      context 'when one office code' do
        let(:office_codes) { %w[A1] }

        it 'does not set the selected_office_code' do
          described_class.from_omniauth(auth)
          expect(described_class.last.selected_office_code).to eq('A1')
        end
      end
    end

    context 'existing user' do
      let!(:provider) do
        described_class.create!(auth_provider: auth.provider, uid: auth.uid, selected_office_code: 'A1')
      end

      context 'who has an existing office code' do
        context 'that is in the list of office codes' do
          let(:office_codes) { %w[A1] }

          it 'does not change the office code' do
            described_class.from_omniauth(auth)
            expect(provider.reload.selected_office_code).to eq('A1')
          end
        end

        context 'that is not in the list of office codes' do
          context 'when multiple office codes' do
            let(:office_codes) { %(A2 A3) }

            it 'clears the office code' do
              described_class.from_omniauth(auth)
              expect(provider.reload.selected_office_code).to be_nil
            end
          end

          context 'when single office code' do
            let(:office_codes) { %w[A2] }

            it 'updates the office code' do
              described_class.from_omniauth(auth)
              expect(provider.reload.selected_office_code).to eq('A2')
            end
          end
        end
      end
    end
  end
end
