require 'rails_helper'

RSpec.describe Assess::BaseViewModel do
  let(:implementation_class) { Assess::V1::ClaimSummary }
  let(:claim) do
    instance_double(SubmittedClaim, json_schema_version: 1, data: data, attributes: { state: }, events: event)
  end
  let(:event) { Event }
  let(:state) { 'granted' }

  describe '#build' do
    context 'for a single object' do
      let(:data) { { 'laa_reference' => 'LA111', 'defendants' => [{ 'some' => 'data' }], 'state' => 'granted' } }

      it 'returns an instance with the correct attributes' do
        result = described_class.build(:assessed_claims, claim)
        expect(result).to have_attributes(
          state: 'granted',
        )
      end

      it 'builds the object from the hash of attributes' do
        summary = described_class.build(:claim_summary, claim)
        expect(summary).to have_attributes(
          laa_reference: 'LA111',
          defendants: [{ 'some' => 'data' }]
        )
      end
    end

    context 'for a nested object' do
      let(:data) do
        { 'work_items' => [{ 'work_type' => { 'value' => 'first' } }, { 'work_type' => { 'value' => 'second' } }] }
      end

      it 'builds the object from the array of hashes of attributes' do
        work_items = described_class.build(:work_item, claim, 'work_items')
        expect(work_items.count).to eq(2)
        expect(work_items[0]).to have_attributes(work_type: TranslationObject.new('value' => 'first'))
        expect(work_items[1]).to have_attributes(work_type: TranslationObject.new('value' => 'second'))
      end

      context 'when adjustments exist' do
        let(:claim) do
          create(:submitted_claim).tap do |claim|
            create(:event, :edit_count, submitted_claim: claim)
          end
        end

        it 'correctly applies adjustments' do
          letters, calls = *described_class.build(:letter_and_call, claim, 'letters_and_calls')
          expect(letters.adjustments).to eq(claim.events)
          expect(calls.adjustments).to eq([])
        end
      end
    end
  end
end
