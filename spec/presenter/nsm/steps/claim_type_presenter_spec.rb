require 'rails_helper'

RSpec.describe Nsm::Tasks::ClaimType, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      firm_office:,
      solicitor:,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:firm_office) { nil }
  let(:solicitor) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/claim_type") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  describe '#can_start?' do
    it { expect(subject).to be_can_start }
  end

  it_behaves_like 'a task with generic complete?', Nsm::Steps::ClaimTypeForm
end
