require 'rails_helper'

RSpec.describe Nsm::Tasks::CostSummary, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      navigation_stack:,
      disbursements:,
      has_disbursements:
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:navigation_stack) { [] }
  let(:disbursements) { [] }
  let(:has_disbursements) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/cost_summary") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    context 'when has_disbursements is no' do
      let(:has_disbursements) { 'no' }

      it { expect(subject).to be_can_start }
    end

    context 'when has_disbursements is nil' do
      it { expect(subject).not_to be_can_start }
    end

    context 'when has_disbursements is yes' do
      let(:has_disbursements) { 'yes' }

      it_behaves_like 'a task with generic can_start?', Nsm::Tasks::Disbursements
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
