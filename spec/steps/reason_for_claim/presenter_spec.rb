require 'rails_helper'

RSpec.describe Tasks::ReasonForClaim, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      reasons_for_claim: reasons_for_claim,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:reasons_for_claim) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/reason_for_claim") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    let(:defendant_details) { instance_double(Tasks::DefendantDetails, status:) }

    before do
      allow(Tasks::DefendantDetails).to receive(:new).and_return(defendant_details)
    end

    context 'when case details are complete' do
      let(:status) { TaskStatus::COMPLETED }

      it { expect(subject).to be_can_start }
    end

    context 'when case details are not complete' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it { expect(subject).not_to be_can_start }
    end
  end

  describe '#completed?' do
    let(:form) { instance_double(Steps::ReasonForClaimForm, valid?: valid) }
    let(:valid) { true }

    before do
      allow(Steps::ReasonForClaimForm).to receive(:new).and_return(form)
    end

    context 'when reasons_for_claim has any values' do
      let(:reasons_for_claim) { [:value] }

      context 'when valid is true' do
        it { expect(subject).to be_completed }
      end

      context 'when valid is false' do
        let(:valid) { false }

        it { expect(subject).not_to be_completed }
      end
    end

    context 'when reasons_for_claim is empty' do
      it { expect(subject).not_to be_completed }
    end
  end
end
