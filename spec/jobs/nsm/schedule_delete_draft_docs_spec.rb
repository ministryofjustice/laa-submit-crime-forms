require 'rails_helper'

RSpec.describe Nsm::ScheduleDeleteDraftDocs do
  let(:claim) { create(:claim, state:, updated_at:) }

  before do
    claim
  end

  describe '#perform' do
    context 'when GDPR claims present' do
      let(:state) { 'draft' }
      let(:updated_at) { 6.months.ago }

      it 'create job per claim' do
        expect(Nsm::DeleteDraftDocs).to receive(:perform_later).with(claim)
        described_class.new.perform
      end
    end

    context 'when no GDPR claims present' do
      let(:state) { 'draft' }
      let(:updated_at) { 5.months.ago }

      it 'returns false' do
        expect(described_class.new.perform).to be(false)
      end
    end
  end

  describe '#filterd_claims' do
    context 'when PA' do
      context 'when last_updated_at' do
        describe 'greater than 6 months ago' do
          let(:state) { 'granted' }
          let(:updated_at) { 6.months.ago }

          it 'is not included' do
            expect(described_class.new.filtered_claims).not_to include(claim)
          end
        end
      end
    end

    context 'when NSM' do
      context 'when last_updated_at' do
        describe 'greater than 6 months ago' do
          let(:state) { 'draft' }
          let(:updated_at) { 6.months.ago }

          it 'is included' do
            expect(described_class.new.filtered_claims).to include(claim)
          end
        end

        describe 'less than 6 months ago' do
          let(:state) { 'draft' }
          let(:updated_at) { 1.day.ago }

          it 'is excluded' do
            expect(described_class.new.filtered_claims).not_to include(claim)
          end
        end
      end
    end
  end
end
