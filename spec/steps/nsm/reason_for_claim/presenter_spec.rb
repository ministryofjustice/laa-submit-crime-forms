require 'rails_helper'

RSpec.describe Nsm::Tasks::ReasonForClaim, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      reasons_for_claim:,
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

  it_behaves_like 'a task with generic can_start?', Nsm::Tasks::CaseDisposal

  describe '#completed?' do
    let(:form) { instance_double(Nsm::Steps::ReasonForClaimForm, valid?: valid) }
    let(:valid) { true }

    before do
      allow(Nsm::Steps::ReasonForClaimForm).to receive(:build).and_return(form)
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
