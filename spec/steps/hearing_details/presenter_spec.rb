require 'rails_helper'

RSpec.describe Tasks::HearingDetails, type: :system do
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
    it { expect(subject.path).to eq("/applications/#{id}/steps/hearing_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Tasks::CaseDetails
  it_behaves_like 'a task with generic complete?', Steps::HearingDetailsForm
end
