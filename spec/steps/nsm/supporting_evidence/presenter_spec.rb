require 'rails_helper'

RSpec.describe Nsm::Tasks::SupportingEvidence, type: :system do
  subject { described_class.new(application:) }

  let(:application) { create(:claim, attributes) }
  let(:attributes) { { id: } }
  let(:id) { SecureRandom.uuid }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/supporting_evidence") }
  end

  it_behaves_like 'a task with generic complete?', Nsm::Steps::SupportingEvidenceForm
end
