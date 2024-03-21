require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'current_office_code' do
    before do
      allow(helper).to receive(:current_provider).and_return(provider)
    end

    context 'current_provider is not set' do
      let(:provider) { nil }

      it 'returns nil' do
        expect(helper.current_office_code).to be_nil
      end
    end

    context 'when selected_office_code is present' do
      let(:provider) { instance_double(Provider, selected_office_code: 'A1') }

      it 'returns the selected_office_code' do
        expect(helper.current_office_code).to eq('A1')
      end
    end

    context 'when no selected_office_code but office_codes are present' do
      let(:provider) { instance_double(Provider, selected_office_code: nil, office_codes: %w[A2 A3]) }

      it 'returns the first office code' do
        expect(helper.current_office_code).to be_nil
      end
    end

    context 'when no selected_office_code or office_codes are present' do
      let(:provider) { instance_double(Provider, selected_office_code: nil, office_codes: []) }

      it 'returns nil' do
        expect(helper.current_office_code).to be_nil
      end
    end
  end

  describe '#maat_required?' do
    let(:form) { double(:form, application:) }
    let(:application) { double(:application, claim_type:) }

    context 'when claim type is not BREACH_OF_INJUNCTION' do
      let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE.to_s }

      it { expect(helper).to be_maat_required(form) }
    end

    context 'when claim type is BREACH_OF_INJUNCTION' do
      let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

      it { expect(helper).not_to be_maat_required(form) }
    end
  end

  describe '#relevant_prior_authority_list_anchor' do
    let(:application) { build(:prior_authority_application, status: 'draft') }

    it { expect(helper.relevant_prior_authority_list_anchor(application)).to eq(:draft) }
  end
end
