require 'rails_helper'

RSpec.describe Nsm::Tasks::CaseDisposal, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      plea:
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:plea) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/case_disposal") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Nsm::Tasks::HearingDetails
  it_behaves_like 'a task with generic complete?', Nsm::Steps::CaseDisposalForm

  describe '#in_progress?' do
    it { expect(subject).not_to be_in_progress }
  end
end
