require 'rails_helper'

RSpec.describe Nsm::Tasks::Disbursements, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      disbursements:,
      viewed_steps:,
      has_disbursements:
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:disbursements) { [disbursement] }
  let(:disbursement) { Disbursement.new(id: SecureRandom.uuid) }
  let(:viewed_steps) { [] }
  let(:has_disbursements) { nil }

  describe '#path' do
    # This is calling the DecisionTree code so not full tested all options here
    context 'no disbursements' do
      let(:disbursements) { [] }

      it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/disbursement_add") }
    end

    context 'any valid disbursements' do
      let(:disbursement) { build(:disbursement, :valid) }

      it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/disbursements") }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Nsm::Tasks::LettersCalls

  describe 'in_progress?' do
    context 'viewed_steps include disbursement add screen' do
      before do
        viewed_steps << 'disbursement_add'
      end

      it { expect(subject).to be_in_progress }
    end

    context 'viewed_steps does not include disbursements paths' do
      it { expect(subject).not_to be_in_progress }
    end
  end

  describe '#completed?' do
    context 'when has_disbursements is no' do
      let(:has_disbursements) { 'no' }

      it { expect(subject).to be_completed }
    end

    context 'when has_disbursements is not no (yes or nil)' do
      let(:has_disbursements) { 'yes' }

      context 'when no disbursements exist' do
        let(:disbursements) { [] }

        it { expect(subject).not_to be_completed }
      end

      context 'when disbursement_type exist' do
        let(:disbursement_type_form) { double(:disbursement_type_form, validate: true, valid?: types_valid) }
        let(:disbursement_cost_form) { double(:disbursement_type_form, validate: true, valid?: costs_valid, 'add_another=': true) }

        before do
          allow(Nsm::Steps::DisbursementTypeForm).to receive(:build).and_return(disbursement_type_form)
          allow(Nsm::Steps::DisbursementCostForm).to receive(:build).and_return(disbursement_cost_form)
        end

        context 'when types are not valid' do
          let(:types_valid) { false }
          let(:costs_valid) { true }

          it { expect(subject).not_to be_completed }
        end

        context 'when costs are not valid' do
          let(:types_valid) { false }
          let(:costs_valid) { false }

          it { expect(subject).not_to be_completed }
        end

        context 'when they are all valid' do
          let(:types_valid) { true }
          let(:costs_valid) { true }

          it { expect(subject).to be_completed }
        end
      end
    end
  end
end
