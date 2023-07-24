require 'rails_helper'

RSpec.describe Tasks::CostSummary, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      navigation_stack: navigation_stack,
      disbursements: disbursements,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:navigation_stack) { [] }
  let(:disbursements) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/cost_summary") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  context '#can_start?' do
    context 'when disbursement_add page has not been visited' do
      it { expect(subject).not_to be_can_start }
    end

    context 'when disbursement_add page has been visited' do
      before do
        navigation_stack << edit_steps_disbursement_add_path(application)
      end

      context 'when no disbursements exist' do
        it { expect(subject).to be_can_start }
      end

      context 'when disbursements exist' do
        let(:disbursements) { [build(:disbursement, :valid)] }

        it_behaves_like 'a task with generic can_start?', Tasks::Disbursements
      end
    end
  end

  describe '#completed?' do
    context 'cost_summary is last page in the navigation stack' do
      let(:navigation_stack) { ["/applications/#{id}/steps/cost_summary"] }

      it { expect(subject).not_to be_completed }
    end

    context 'cost_summary is not in the navigation stack' do
      let(:navigation_stack) { ["/applications/#{id}/steps/apples"] }

      it { expect(subject).not_to be_completed }
    end

    context 'cost_summary is not the last page in the navigation stack' do
      let(:navigation_stack) { ["/applications/#{id}/steps/cost_summary", '/foo'] }

      it { expect(subject).to be_completed }
    end
  end
end
