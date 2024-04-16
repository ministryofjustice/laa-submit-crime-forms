require 'rails_helper'

RSpec.describe AppStoreUpdateProcessor do
  let(:arbitrary_fixed_date) { '2021-12-01T23:24:58.846345' }

  describe 'call' do
    let(:response) do
      {
        'application_id' => application.id,
        'version' => 2,
        'application_state' => 'granted',
        'application_risk' => 'high',
        'application_type' => 'crm4',
        'updated_at' => arbitrary_fixed_date,
        'application' => { 'big-blob' => 'of-data' }
      }
    end
    let(:application) { create(:prior_authority_application) }

    before do
      allow(PriorAuthority::AssessmentSyncer).to receive(:call)
      described_class.call(response, is_full:)
    end

    context 'when response is explicitly flagged as being "full"' do
      let(:is_full) { true }

      it 'passes the full record on to AssessmentSyncer' do
        expect(PriorAuthority::AssessmentSyncer).to have_received(:call).with(application, record: response)
      end
    end

    context 'when response is not explicitly flagged as being "full"' do
      let(:is_full) { false }

      it 'does not pass the record on to AssessmentSyncer' do
        expect(PriorAuthority::AssessmentSyncer).to have_received(:call).with(application, record: nil)
      end
    end
  end
end
