require 'rails_helper'

RSpec.describe Nsm::Tasks::SupportingEvidence, type: :system do
  subject { described_class.new(application:) }

  let(:application) { create(:claim, attributes) }
  let(:attributes) { { id:, gdpr_documents_deleted: } }
  let(:id) { SecureRandom.uuid }
  let(:gdpr_documents_deleted) { false }

  describe '#path' do
    it { expect(subject.path).to eq("/non-standard-magistrates/applications/#{id}/steps/supporting_evidence") }
  end

  describe '#complete?' do
    it { expect(subject.complete?).to be false }

    context 'claim has supporting evidence' do
      let(:application) { create(:claim, :with_evidence, attributes) }

      it { expect(subject.complete?).to be true }

      context 'claim has gdpr_documents_deleted as true' do
        let(:gdpr_documents_deleted) { true }

        it { expect(subject.complete?).to be false }
      end
    end
  end
end
