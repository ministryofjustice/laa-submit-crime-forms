require 'rails_helper'

RSpec.describe Providers::Gatekeeper do
  subject(:gatekeeper) { described_class.new(auth_info) }

  before do
    allow(Rails.configuration.x.gatekeeper)
      .to receive(:office_codes)
      .and_return(office_codes_from_config)
  end

  let(:auth_info) do
    double(
      email: 'test@example.com',
      office_codes: user_office_codes,
    )
  end

  let(:user_office_codes) { %w[1A123B 2A555X] }

  describe '#provider_enrolled?' do
    context 'when no service is allowed for their office' do
      let(:office_codes_from_config) { { '9A999B': ['crm4'] } }

      it 'checks if the email is enrolled' do
        expect(gatekeeper).to receive(:email_enrolled?)
        gatekeeper.provider_enrolled?
      end

      it 'checks if the all providers enrolled' do
        expect(gatekeeper).to receive(:all_enrolled?)
        gatekeeper.provider_enrolled?
      end

      it 'checks if any office codes are enrolled' do
        expect(gatekeeper).to receive(:office_enrolled?)
        gatekeeper.provider_enrolled?
      end

      it 'returns false when no service is specified' do
        expect(gatekeeper.provider_enrolled?).to be(false)
      end

      it 'returns false when any service is specified' do
        expect(gatekeeper.all_enrolled?(service: :crm4)).to be(false)
        expect(gatekeeper.all_enrolled?(service: :crm5)).to be(false)
        expect(gatekeeper.all_enrolled?(service: :crm7)).to be(false)
      end
    end

    context 'when ALL have access to crm5 BUT only crm4 for their office code' do
      let(:office_codes_from_config) do
        {
          ALL: ['crm5'],
          '1A123B': ['crm4']
        }
      end

      it 'returns true when no service is specified' do
        expect(gatekeeper.provider_enrolled?).to be(true)
      end

      it 'returns true for the service allowed by ALL' do
        expect(gatekeeper.provider_enrolled?(service: :crm5)).to be(true)
      end

      it 'returns true for the service allowed for their office' do
        expect(gatekeeper.provider_enrolled?(service: :crm4)).to be(true)
      end

      it 'returns false for the service not allowed by ALL or their office' do
        expect(gatekeeper.provider_enrolled?(service: :crm7)).to be(false)
      end
    end
  end

  describe '#all_enrolled?' do
    context 'when ALL is specified for one service' do
      let(:office_codes_from_config) { { ALL: ['crm5'] } }

      it 'returns true when no service is specified' do
        expect(gatekeeper.all_enrolled?).to be(true)
      end

      it 'returns true when an allowed service is specified' do
        expect(gatekeeper.all_enrolled?(service: :crm5)).to be(true)
      end

      it 'returns false when disallowed service is specified' do
        expect(gatekeeper.all_enrolled?(service: :crm4)).to be(false)
      end
    end

    context 'when ALL is NOT specified in the allow list and their office code has none' do
      let(:office_codes_from_config) { { '9A999B': %w[crm7 crm4 crm5] } }

      it 'returns false when no service is specified' do
        expect(gatekeeper.all_enrolled?).to be(false)
      end

      it 'returns false when service is specified' do
        expect(gatekeeper.all_enrolled?(service: :crm4)).to be(false)
        expect(gatekeeper.all_enrolled?(service: :crm5)).to be(false)
        expect(gatekeeper.all_enrolled?(service: :crm7)).to be(false)
      end
    end

    context 'when ALL is specified with no services and their office code has none' do
      let(:office_codes_from_config) { { ALL: [] } }

      it 'returns false when no service is specified' do
        expect(gatekeeper.all_enrolled?).to be(false)
      end

      it 'returns false when service is specified' do
        expect(gatekeeper.all_enrolled?(service: :crm4)).to be(false)
        expect(gatekeeper.all_enrolled?(service: :crm5)).to be(false)
        expect(gatekeeper.all_enrolled?(service: :crm7)).to be(false)
      end
    end
  end

  describe '#office_enrolled?' do
    let(:office_codes_from_config) { { '1A123B': ['crm4'] } }

    context 'when any of the office codes are in the allow list' do
      it 'returns true when no service is specified' do
        expect(gatekeeper.office_enrolled?).to be(true)
      end

      it 'returns true when an allowed service is specified' do
        expect(gatekeeper.office_enrolled?(service: :crm4)).to be(true)
      end

      it 'returns false when a disallowed service is specified' do
        expect(gatekeeper.office_enrolled?(service: :crm7)).to be(false)
      end
    end

    context 'when no office codes are in the allow list' do
      let(:user_office_codes) { %w[1X000X] }

      it 'returns false when no service is specified' do
        expect(gatekeeper.office_enrolled?).to be(false)
      end

      it 'returns false when a service is specified' do
        expect(gatekeeper.office_enrolled?(service: :crm4)).to be(false)
      end
    end
  end
end
