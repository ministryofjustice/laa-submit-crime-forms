require 'rails_helper'

RSpec.describe Nsm::DeleteDraftDocs do
  let!(:claim) { create(:claim) }

  describe '#perform' do
    before do
      allow(LaaCrimeFormsCommon::NSM::DeleteDocumentService).to receive(:call).with(claim).and_return(true)
      described_class.new.perform(claim)
    end

    xit 'creates event' do
      expect(claim.reload.events.last.event_type).to eq('draft_documents_deleted')
    end

    xit 'calls DeleteDocumentService with claim' do
      expect(LaaCrimeFormsCommon::NSM::DeleteDocumentService).to receive(:call).with(claim)
    end
  end
end
