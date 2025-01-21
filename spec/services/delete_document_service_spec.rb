require 'rails_helper'

RSpec.describe DeleteDocumentService do
  before do
    allow(File).to receive(:exist?).and_return(true)

    allow(FileUtils).to receive(:remove).with('test_path').and_return(true)
  end

  context 'when a claim is a draft' do
    let(:claim) { create(:claim, :complete, :as_draft) }

    it 'has no evidence after being deleted' do
      expect(claim.supporting_evidence).not_to eq([])

      described_class.call(claim.id)
      claim.reload

      expect(claim.supporting_evidence).to eq([])
      expect(claim.gdpr_documents_deleted).to be(true)
    end

    it 'does not try to remove a non-existent file' do
      allow(File).to receive(:exist?).and_return(false)
      allow(FileUtils).to receive(:remove).with('test_path').and_return(false)

      expect_any_instance_of(FileUpload::FileUploader).not_to receive(:destroy)

      expect(claim.supporting_evidence).not_to eq([])

      described_class.call(claim.id)
      claim.reload

      expect(claim.supporting_evidence).to eq([])
      expect(claim.gdpr_documents_deleted).to be(true)
    end
  end

  context 'when a claim is not a draft' do
    let(:claim) { create(:claim, :complete, :as_submitted) }

    it 'nothing changes' do
      expect(claim.supporting_evidence).not_to eq([])

      described_class.call(claim.id)
      claim.reload

      expect(claim.supporting_evidence).not_to eq([])
      expect(claim.gdpr_documents_deleted).to be_nil
    end
  end
end
