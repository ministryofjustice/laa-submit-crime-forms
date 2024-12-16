require 'rails_helper'

RSpec.describe SubmitToAppStore::PriorAuthority::EventBuilder do
  describe '.call' do
    let(:application) { create(:prior_authority_application, state:, prison_law:) }
    let(:prison_law) { true }
    let(:random_id) { 'random-id' }

    before do
      allow(SecureRandom).to receive(:uuid).and_return(random_id)
    end

    context 'when application is in submitted state' do
      let(:state) { :submitted }

      it 'returns an empty array' do
        expect(described_class.call(application)).to eq []
      end
    end

    context 'when application is provider_updated' do
      let(:state) { :provider_updated }

      context 'when application has not changed' do
        it 'returns an event with no corrected info' do
          expect(described_class.call(application)).to eq(
            [
              {
                id: random_id,
                details: {
                  comment: nil,
                  corrected_info: false,
                  documents: []
                },
                event_type: 'provider_updated'
              }
            ]
          )
        end
      end

      context 'when application has further information added' do
        let(:application) do
          create(:prior_authority_application, :with_further_information_supplied,
                 app_store_updated_at: DateTime.now - 1.day,
                 state: state)
        end
        let(:further_info_documents) { application.further_informations.order(:created_at).last.supporting_documents }

        it 'returns an event with further info comment' do
          expect(described_class.call(application)).to eq(
            [
              {
                id: random_id,
                details: {
                  comment: 'here is the extra information you requested',
                  corrected_info: false,
                  documents: further_info_documents
                },
                event_type: 'provider_updated'
              }
            ]
          )
        end
      end

      context 'when a section has changed' do
        let(:application) do
          create(:prior_authority_application, :with_corrections,
                 app_store_updated_at: DateTime.now - 1.day,
                 state: state)
        end

        it 'lists the change' do
          expect(described_class.call(application).first.dig(:details, :corrected_info)).to be(true)
        end
      end
    end
  end
end
