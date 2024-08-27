require 'rails_helper'

RSpec.describe Nsm::Tasks::FirmDetails, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      firm_office:,
      solicitor:,
      office_code:,
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:firm_office) { nil }
  let(:solicitor) { nil }
  let(:office_code) { nil }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/firm_details") }
  end

  describe '#not_applicable?' do
    it { expect(subject).not_to be_not_applicable }
  end

  it_behaves_like 'a task with generic can_start?', Nsm::Tasks::ClaimType

  describe '#complete?' do
    let(:solicitor) { create :solicitor, :full }
    let(:firm_office) { create :firm_office, :full }
    let(:office_code) { '12345' }

    it { expect(subject).to be_completed }

    context 'when contact details have not been saved' do
      let(:solicitor) { create :solicitor, :valid }

      it { expect(subject).not_to be_completed }
    end

    context 'when firm details have not been saved' do
      let(:solicitor) { create :solicitor }

      it { expect(subject).not_to be_completed }
    end
  end
end
