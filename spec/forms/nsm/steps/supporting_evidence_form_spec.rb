require 'rails_helper'

RSpec.describe Nsm::Steps::SupportingEvidenceForm do
  let(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      send_by_post:
    }
  end
  let(:application) { build(:claim) }
  let(:gdpr_documents_deleted) { false }

  context 'when send_by_post is yes' do
    let(:send_by_post) { 'yes' }

    it 'is valid' do
      expect(form).to be_valid
    end

    it 'saves the form' do
      expect(form.save).to be_truthy
    end
  end

  context 'when send_by_post is no' do
    let(:send_by_post) { 'no' }

    it 'is not valid without supporting evidence' do
      expect(form).to be_valid
    end

    context 'when there is already supporting evidence' do
      let(:application) do
        build(
          :claim,
          :with_evidence,
          gdpr_documents_deleted:
        )
      end

      it 'is valid' do
        expect(form).to be_valid
      end

      it 'saves the form' do
        expect(form.save).to be_truthy
      end

      context 'when the gdpr_documents_deleted is true' do
        let(:gdpr_documents_deleted) { true }

        it 'resets the gdpr_documents_deleted flag when form saved' do
          form.save
          expect(application.gdpr_documents_deleted).to be false
        end
      end
    end
  end
end
