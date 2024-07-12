require 'rails_helper'

RSpec.describe Fixes::MultiplePrimaryQuoteFixer do
  describe '#identify' do
    let(:application) { create :prior_authority_application }
    let(:other_application) { create :prior_authority_application, :with_complete_prison_law }
    let(:first_primary) { create :quote, :primary, prior_authority_application: application }
    let(:second_primary) { create :quote, :primary, prior_authority_application: application }

    before do
      other_application
      first_primary
      second_primary
    end

    it 'correctly identifies' do
      expect(described_class.new.identify).to eq([[application.id, application.status, application.laa_reference]])
    end
  end

  describe '#fix' do
    let(:application) { create :prior_authority_application, :with_complete_prison_law, quotes: [], status: status }
    let(:status) { 'submitted' }
    let(:first_primary) { create :quote, :primary, prior_authority_application: application }

    let(:second_primary) do
      create :quote, :per_hour, :primary, period: nil, cost_per_hour: nil, prior_authority_application: application
    end

    let(:uploader) { instance_double(FileUpload::FileUploader, destroy: true) }
    let(:client) { instance_double(AppStoreClient, put: :success) }

    before do
      first_primary
      second_primary
      allow(FileUpload::FileUploader).to receive(:new).and_return(uploader)
      allow(AppStoreClient).to receive(:new).and_return(client)

      described_class.new.fix
    end

    it 'deletes the incomplete quote' do
      expect(application.quotes.where(primary: true).count).to eq 1
      expect(application.reload.primary_quote).to eq first_primary
    end

    it 'preserves the status' do
      expect(application.reload).to be_submitted
    end

    it 'deletes the incomplete quote uploaded file' do
      expect(uploader).to have_received(:destroy).with(second_primary.document.file_path)
    end

    it 'triggers a PUT to the app store with a status the app store will accept' do
      expect(client).to have_received(:put) do |args|
        expect(args[:application_id]).to eq application.id
        expect(args[:application_state]).to eq 'provider_updated'
      end
    end

    context 'when status is draft' do
      let(:status) { 'draft' }

      it 'does not bother the app store' do
        expect(client).not_to have_received(:put)
      end
    end

    context 'when second quote has no document' do
      let(:second_primary) do
        create :quote, :per_hour,
               :primary, period: nil, cost_per_hour: nil, prior_authority_application: application,
               document: build(:quote_document, file_path: nil)
      end

      it 'does not try to delete the incomplete quote uploaded file' do
        expect(uploader).not_to have_received(:destroy)
      end
    end
  end
end
