require 'rails_helper'

RSpec.describe AppStoreListService do
  describe '.submitted' do
    let(:client) { instance_double(AppStoreClient, search: response) }
    let(:response) do
      {
        metadata: { total_results: 0 },
        raw_data: []
      }
    end
    let(:provider) { create(:provider, office_codes: %w[a b]) }
    let(:params) { ActionController::Parameters.new(page: 5, sort_direction: 'ascending', sort_by: local_sort_by_param) }
    let(:local_sort_by_param) { 'ufn' }
    let(:service) { :nsm }
    let(:expected_payload) do
      {
        'page' => 5,
        'sort_direction' => 'ascending',
        :sort_by => expected_sort_by,
        :per_page => 10,
        :application_type => expected_application_type,
        :account_number => %w[a b],
        :status_with_assignment => %i[in_progress not_assigned provider_updated]
      }
    end
    let(:expected_sort_by) { 'ufn' }
    let(:expected_application_type) { 'crm7' }

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
    end

    it 'searches for submitted applications' do
      described_class.submitted(provider, params, service:)
      expect(client).to have_received(:search).with(expected_payload)
    end

    it 'returns a SubmissionList' do
      expect(described_class.submitted(provider, params, service:)).to be_a SubmissionList
    end

    context 'when service is PA' do
      let(:service) { :prior_authority }
      let(:expected_application_type) { 'crm4' }

      it 'modifies appropriately' do
        described_class.submitted(provider, params, service:)
        expect(client).to have_received(:search).with(expected_payload)
      end
    end

    context 'when sorting by defendant' do
      let(:local_sort_by_param) { 'defendant' }
      let(:expected_sort_by) { 'client_name' }

      it 'modifies appropriately' do
        described_class.submitted(provider, params, service:)
        expect(client).to have_received(:search).with(expected_payload)
      end
    end

    context 'when sorting by account' do
      let(:local_sort_by_param) { 'account' }
      let(:expected_sort_by) { 'account_number' }

      it 'modifies appropriately' do
        described_class.submitted(provider, params, service:)
        expect(client).to have_received(:search).with(expected_payload)
      end
    end

    context 'when sorting by last updated' do
      let(:local_sort_by_param) { 'last_updated' }
      let(:expected_sort_by) { 'last_state_change' }

      it 'modifies appropriately' do
        described_class.submitted(provider, params, service:)
        expect(client).to have_received(:search).with(expected_payload)
      end
    end
  end
end
