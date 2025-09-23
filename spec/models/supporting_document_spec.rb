require 'rails_helper'

RSpec.describe SupportingDocument do
  context 'for PA quotes' do
    subject do
      quote = create(:quote, prior_authority_application: application)
      application.update!(primary_quote: quote)
      create(:quote_document, documentable: quote)
    end

    describe 'remove_old_file' do
      context 'for a sent-back application' do
        let(:application) { build(:prior_authority_application, :as_sent_back) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'fires if file_path does change' do
          expect(DeleteAttachment).to receive(:set).with(wait: 24.hours).and_return(
            double(perform_later: true)
          )

          subject.update(file_path: 'new_test_path')
        end
      end

      context 'for a draft application' do
        let(:application) { build(:prior_authority_application, :as_draft) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'does nothing if the application is not sent_back' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_path: 'new_test_path')
        end
      end
    end
  end

  context 'for NSM supporting evidence' do
    subject do
      create(:supporting_evidence, documentable: claim)
    end

    describe 'remove_old_file' do
      context 'for a sent-back claim' do
        let(:claim) { create(:claim, :as_sent_back) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'fires if file_path does change' do
          expect(DeleteAttachment).to receive(:set).with(wait: 24.hours).and_return(
            double(perform_later: true)
          )

          subject.update(file_path: 'new_test_path')
        end
      end

      context 'for a draft application' do
        let(:claim) { create(:claim, :as_draft) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'does nothing if the application is not sent_back' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_path: 'new_test_path')
        end
      end
    end
  end

  context 'for NSM further information' do
    subject do
      claim.further_informations.first.supporting_documents.first
    end

    describe 'remove_old_file' do
      context 'for a sent-back claim' do
        let(:claim) { create(:claim, :with_further_information_supplied) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'fires if file_path does change' do
          expect(DeleteAttachment).to receive(:set).with(wait: 24.hours).and_return(
            double(perform_later: true)
          )

          subject.update(file_path: 'new_test_path')
        end
      end

      context 'for a draft application' do
        let(:claim) { create(:claim, :with_further_information_supplied, :as_draft) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'does nothing if the application is not sent_back' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_path: 'new_test_path')
        end
      end
    end
  end

  context 'for PA further information' do
    subject do
      application.further_informations.first.supporting_documents.first
    end

    describe 'remove_old_file' do
      context 'for a sent-back claim' do
        let(:application) { create(:prior_authority_application, :with_further_information_supplied) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'fires if file_path does change' do
          expect(DeleteAttachment).to receive(:set).with(wait: 24.hours).and_return(
            double(perform_later: true)
          )

          subject.update(file_path: 'new_test_path')
        end
      end

      context 'for a draft application' do
        let(:application) { create(:prior_authority_application, :with_further_information_supplied, :as_draft) }

        it 'does nothing if file_path does not change' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_size: 53)
        end

        it 'does nothing if the application is not sent_back' do
          expect(DeleteAttachment).not_to receive(:set)

          subject.update(file_path: 'new_test_path')
        end
      end
    end
  end
end
