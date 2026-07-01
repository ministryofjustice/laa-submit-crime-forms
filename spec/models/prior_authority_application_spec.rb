require 'rails_helper'

RSpec.describe PriorAuthorityApplication do
  subject(:prior_authority_application) do
    create(:prior_authority_application, :with_firm_and_solicitor, :with_created_alternative_quotes,
           :with_created_primary_quote, :with_additional_costs)
  end

  describe '#provider' do
    it 'belongs to a provider' do
      expect(prior_authority_application.provider).to be_a(Provider)
    end
  end

  describe '#solicitor' do
    it 'belongs to a solcitor' do
      expect(prior_authority_application.solicitor).to be_a(Solicitor)
    end
  end

  describe '#firm_office' do
    it 'belongs to a firm_office' do
      expect(prior_authority_application.firm_office).to be_a(FirmOffice)
    end
  end

  describe '#total_cost_gbp' do
    context 'claim has quotes' do
      it 'calculates the total cost and shows it in pounds' do
        expect(prior_authority_application.total_cost_gbp).to eq('£186.67')
      end
    end

    context 'claim has no quotes or additional costs' do
      subject(:prior_authority_application) { create(:prior_authority_application) }

      it 'calculates the total cost and shows it in pounds' do
        expect(prior_authority_application.total_cost_gbp).to be_nil
      end
    end
  end

  describe '#further_information_needed?' do
    context 'a draft application' do
      subject(:prior_authority_application) { create(:prior_authority_application, state: 'draft') }

      it { expect(prior_authority_application).not_to be_further_information_needed }
    end

    context 'a sent back application' do
      subject(:prior_authority_application) do
        create(:prior_authority_application, :with_further_information_request, app_store_updated_at:)
      end

      let(:app_store_updated_at) { DateTime.current - 1.day }

      it { expect(prior_authority_application).to be_further_information_needed }
    end

    context 'a sent back application with no further information' do
      subject(:prior_authority_application)  { create(:prior_authority_application, state: 'sent_back') }

      it { expect(prior_authority_application).not_to be_further_information_needed }
    end
  end

  describe '#destroy_attachments' do
    let(:test_file_path) { 'test_path' }
    let(:file_evidence) { double('file_evidence', file_path: test_file_path) }
    let(:quote_document) { double('document', file_path: test_file_path) }
    let(:quote) { double('quote', document: quote_document) }

    before do
      allow(application).to receive_messages(supporting_documents: [file_evidence], quotes: [quote])
    end

    context 'when application is a draft' do
      let(:application) { create(:prior_authority_application, :full, :with_further_information_supplied, :as_draft) }

      context 'and has a quote without a document' do
        let(:quote) { double('quote', document: nil) }

        it 'removes attachments for drafts without erroring' do
          allow_any_instance_of(FileUpload::FileUploader).to receive(:exists?).with(test_file_path).and_return(true)
          expect_any_instance_of(FileUpload::FileUploader).to receive(:destroy).with(test_file_path).at_least(:once)
          application.destroy
        end
      end

      it 'removes attachments for drafts' do
        allow_any_instance_of(FileUpload::FileUploader).to receive(:exists?).with(test_file_path).and_return(true)
        expect_any_instance_of(FileUpload::FileUploader).to receive(:destroy).with(test_file_path).at_least(:twice)
        application.destroy
      end

      it 'does not attempt to remove files that do not exist' do
        allow_any_instance_of(FileUpload::FileUploader).to receive(:exists?).with(test_file_path).and_return(false)
        expect_any_instance_of(FileUpload::FileUploader).not_to receive(:destroy)
        application.destroy
      end
    end

    context 'when application is not a draft' do
      let(:application) { create(:prior_authority_application, :full, :with_further_information_request, :as_submitted) }

      it 'does not remove attachments for non-drafts' do
        expect_any_instance_of(FileUpload::FileUploader).not_to receive(:exists?)
        expect_any_instance_of(FileUpload::FileUploader).not_to receive(:destroy)
        application.destroy
      end
    end
  end
end
