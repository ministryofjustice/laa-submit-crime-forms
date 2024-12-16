require 'rails_helper'

RSpec.describe AppStore::V1::FurtherInformation do
  describe '#as_json' do
    subject { described_class.new(attributes, parent).as_json }

    let(:parent) { AppStore::V1::Nsm::Claim.new('application_id' => claim.id) }
    let(:claim) { create(:claim) }

    context 'when this has previously been completed' do
      let(:attributes) do
        {
          caseworker_id: SecureRandom.uuid,
          requested_at: 1.hour.ago,
          information_requested: 'AAAAAA',
          information_supplied: 'BBBBB',
          documents: [{
            file_name: 'DDDDD'
          }],
          signatory_name: 'CCCCCC'
        }.as_json
      end

      it 'returns the original attributes unmodified' do
        expect(subject).to eq attributes
      end
    end

    context 'when this has not previously been completed' do
      let(:attributes) do
        {
          caseworker_id: SecureRandom.uuid,
          requested_at: 1.hour.ago,
          information_requested: 'AAAAAA'
        }.as_json
      end

      before do
        further_information = claim.further_informations.create!(attributes.merge(
                                                                   information_supplied: 'BBBB',
                                                                   signatory_name: 'CCCCC'
                                                                 ))
        further_information.supporting_documents.create!(
          file_name: 'EEEEE',
          file_type: 'FFFFF',
          file_size: 12_345,
          file_path: 'GGGGG',
          document_type: 'supporting_document',
        )
      end

      it 'returns the database attributes' do
        expect(subject).to eq(
          attributes.merge(
            information_supplied: 'BBBB',
            signatory_name: 'CCCCC',
            documents: [{
              file_name: 'EEEEE',
              file_type: 'FFFFF',
              file_size: 12_345,
              file_path: 'GGGGG',
              document_type: 'supporting_document',
            }],
          ).as_json
        )
      end
    end
  end
end
