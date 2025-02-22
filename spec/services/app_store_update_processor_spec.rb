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
        'application_type' => application_type,
        'last_updated_at' => arbitrary_fixed_date,
        'application' => { 'big-blob' => 'of-data' }
      }
    end

    context 'when updating a PA application' do
      let(:application_type) { 'crm4' }

      before do
        allow(PriorAuthority::AssessmentSyncer).to receive(:call)
        described_class.call(response)
      end

      context 'when record exists locally' do
        let(:application) { create(:prior_authority_application) }

        it 'passes the full record on to AssessmentSyncer' do
          expect(PriorAuthority::AssessmentSyncer).to have_received(:call).with(application, record: response)
        end

        it 'updates state' do
          expect(application.reload).to be_granted
        end
      end

      context 'when record does not exist locally' do
        let(:application) { build(:prior_authority_application, id: SecureRandom.uuid) }

        it 'does not call AssessmentSyncer' do
          expect(PriorAuthority::AssessmentSyncer).not_to have_received(:call)
        end
      end
    end

    context 'when updating an NSM claim' do
      let(:application_type) { 'crm7' }

      before do
        allow(Nsm::AssessmentSyncer).to receive(:call)
        described_class.call(response)
      end

      context 'when record exists locally' do
        let(:application) { create(:claim) }

        it 'passes the full record on to AssessmentSyncer' do
          expect(Nsm::AssessmentSyncer).to have_received(:call).with(application, record: response)
        end

        it 'updates state' do
          expect(application.reload).to be_granted
        end
      end

      context 'when record does not exist locally' do
        let(:application) { build(:claim, id: SecureRandom.uuid) }

        it 'does not call AssessmentSyncer' do
          expect(Nsm::AssessmentSyncer).not_to have_received(:call)
        end
      end
    end

    context 'when told about an unknown application type, even if the id matches' do
      let(:application_type) { 'crm8' }
      let(:application) { create(:prior_authority_application) }

      before do
        allow(PriorAuthority::AssessmentSyncer).to receive(:call)
        described_class.call(response)
      end

      it 'does not call AssessmentSyncer' do
        expect(PriorAuthority::AssessmentSyncer).not_to have_received(:call)
      end
    end
  end
end
