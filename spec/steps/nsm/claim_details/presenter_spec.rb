require 'rails_helper'

RSpec.describe Nsm::Tasks::ClaimDetails, type: :system do
  subject { described_class.new(application:) }

  let(:application) { create(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      plea:
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:plea) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/claim_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    let(:reason_for_claim) { instance_double(Nsm::Tasks::ReasonForClaim, status:) }

    before do
      allow(Nsm::Tasks::ReasonForClaim).to receive(:new).and_return(reason_for_claim)
    end

    context 'when claim details are complete' do
      let(:status) { TaskStatus::COMPLETED }

      it { expect(subject).to be_can_start }
    end

    context 'when claim details are not complete' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it { expect(subject).not_to be_can_start }
    end
  end

  describe '#completed?' do
    let(:form) { instance_double(Nsm::Steps::ClaimDetailsForm, valid?: valid) }

    before do
      allow(Nsm::Steps::ClaimDetailsForm).to receive(:new).and_return(form)
    end

    context 'when status is valid' do
      let(:valid) { true }

      it { expect(subject).to be_completed }
    end

    context 'when status not is valid' do
      let(:valid) { false }

      it { expect(subject).not_to be_completed }
    end
  end
end
