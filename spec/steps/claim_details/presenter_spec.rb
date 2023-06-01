require 'rails_helper'

RSpec.describe Tasks::ClaimDetails, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.create(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      plea: plea
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:plea) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/claim_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    let(:reason_for_claim) { instance_double(Tasks::ReasonForClaim, status:) }

    before do
      allow(Tasks::ReasonForClaim).to receive(:new).and_return(reason_for_claim)
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
    let(:form) { instance_double(Steps::ClaimDetailsForm, valid?: valid) }

    before do
      allow(Steps::ClaimDetailsForm).to receive(:new).and_return(form)
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
