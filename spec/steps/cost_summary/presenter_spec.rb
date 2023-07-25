require 'rails_helper'

RSpec.describe Tasks::CostSummary, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      navigation_stack: navigation_stack
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:navigation_stack) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/cost_summary") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Tasks::LettersCalls

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
