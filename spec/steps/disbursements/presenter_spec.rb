require 'rails_helper'

RSpec.describe Tasks::Disbursements, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      disbursements: disbursements,
      navigation_stack: navigation_stack,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:disbursements) { [disbursement] }
  let(:disbursement) { Disbursement.new(id: SecureRandom.uuid) }
  let(:navigation_stack) { [] }

  describe '#path' do
    before do
      allow(application.disbursements).to receive(:count).and_return(number_of_disbursements)
    end

    context 'no disbursements' do
      let(:number_of_disbursements) { 0 }

      it { expect(subject.path).to eq("/applications/#{id}/steps/disbursement_type/#{StartPage::NEW_RECORD}") }
    end

    context 'one disbursement' do
      let(:number_of_disbursements) { 1 }

      it { expect(subject.path).to eq("/applications/#{id}/steps/disbursements") }
    end
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Tasks::LettersCalls

  describe 'in_progress?' do
    context 'navigation_stack include edit disbursement_type path' do
      before { navigation_stack << edit_steps_disbursement_type_path(application, disbursement_id: disbursement.id) }

      it { expect(subject).to be_in_progress }
    end

    # context 'navigation_stack include edit disbursements path' do
    #   before { navigation_stack << edit_steps_work_items_path(application) }

    #   it { expect(subject).to be_in_progress }
    # end

    context 'navigation_stack does not include disbursements paths' do
      it { expect(subject).not_to be_in_progress }
    end
  end

  describe '#completed?' do
    context 'when no disbursements exist' do
      let(:disbursements) { [] }

      it { expect(subject).not_to be_completed }
    end

    context 'when disbursement_type exist' do
      let(:disbursement_type_form) { double(:disbursement_type_form, valid?: types_valid) }
      let(:disbursement_cost_form) { double(:disbursement_type_form, valid?: costs_valid) }

      before do
        allow(Steps::DisbursementTypeForm).to receive(:build).and_return(disbursement_type_form)
        allow(Steps::DisbursementCostForm).to receive(:build).and_return(disbursement_cost_form)
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
