require 'rails_helper'

RSpec.describe SubmissionList do
  subject(:submission_list) { described_class.new(search_response.with_indifferent_access, params) }

  let(:params) { ActionController::Parameters.new(page: 1) }

  describe '#pagy' do
    context 'when total_results is not provided' do
      context 'when fewer than PAGE_SIZE rows are fetched' do
        let(:search_response) { { raw_data: [{}] } }

        it 'does not provide a next page' do
          expect(submission_list.pagy.next).to be_nil
        end
      end

      context 'when has_more is true' do
        let(:search_response) { { raw_data: Array.new(AppStoreListService::PAGE_SIZE) { {} }, metadata: { has_more: true } } }

        it 'provides a next page' do
          expect(submission_list.pagy.next).to eq(2)
        end
      end

      context 'when has_more is false' do
        let(:search_response) { { raw_data: Array.new(AppStoreListService::PAGE_SIZE) { {} }, metadata: { has_more: false } } }

        it 'does not provide a next page' do
          expect(submission_list.pagy.next).to be_nil
        end
      end

      context 'when there is one row on page 2' do
        let(:params) { ActionController::Parameters.new(page: 2) }
        let(:search_response) { { raw_data: [{}] } }

        it 'shows one record' do
          expect(submission_list.rows.size).to eq(1)
        end
      end

      context 'when requesting a page beyond available results' do
        let(:params) { ActionController::Parameters.new(page: 2) }
        let(:search_response) { { raw_data: [] } }

        it 'does not raise an overflow error' do
          expect { submission_list.pagy }.not_to raise_error
        end
      end
    end
  end
end
