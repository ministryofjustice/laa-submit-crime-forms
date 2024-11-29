require 'rails_helper'

RSpec.describe AppStoreDetailService do
  describe '.prior_authority' do
    subject { described_class.prior_authority(id, provider) }

    let(:record) { { 'application_id' => id, 'application_state' => 'granted', 'application' => { 'foo' => :bar } } }
    let(:provider) { instance_double(Provider, office_codes: ['OFFICE_CODE']) }
    let(:model) { instance_double(AppStore::V1::PriorAuthority::Application, office_code:) }
    let(:office_code) { 'OFFICE_CODE' }
    let(:local_record) { create(:prior_authority_application, id:, state:) }
    let(:id) { SecureRandom.uuid }
    let(:state) { 'granted' }

    before do
      allow(AppStoreClient).to receive(:new).and_return(instance_double(AppStoreClient, get: record))
      allow(AppStore::V1::PriorAuthority::Application).to receive(:new).and_return(model)
      allow(AppStoreUpdateProcessor).to receive(:call)
      local_record
    end

    it 'instantiates and returns a model' do
      expect(subject).to eq model
      expect(AppStore::V1::PriorAuthority::Application).to have_received(:new).with(
        'application_id' => id, 'application_state' => 'granted', 'foo' => :bar,
      )
    end

    it 'does not call the update processor by default' do
      subject
      expect(AppStoreUpdateProcessor).not_to have_received(:call)
    end

    context 'when provider does not have office code' do
      let(:office_code) { 'OTHER_OFFICE_CODE' }

      it 'raises an error' do
        expect { subject }.to raise_error Errors::ApplicationNotFound
      end
    end

    context 'when local record needs syncing' do
      let(:state) { 'submitted' }

      it 'calls the update processor by default' do
        subject
        expect(AppStoreUpdateProcessor).to have_received(:call).with(
          record, local_record
        )
      end
    end
  end
end
