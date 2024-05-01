require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
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
    let(:application) { build(:prior_authority_application) }

    it 'returns draft for draft status' do
      allow(application).to receive(:status).and_return('draft')
      expect(helper.relevant_prior_authority_list_anchor(application)).to eq(:draft)
    end

    it 'returns submitted for submitted status' do
      allow(application).to receive(:status).and_return('submitted')
      expect(helper.relevant_prior_authority_list_anchor(application)).to eq(:submitted)
    end

    it 'returns reviewed for all statuses other than draft or submitted' do
      allow(application).to receive(:status).and_return('whatever')
      expect(helper.relevant_prior_authority_list_anchor(application)).to eq(:reviewed)
    end
  end
end
