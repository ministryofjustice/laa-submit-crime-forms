require 'rails_helper'

RSpec.describe Assess::V1::TravelAndWaiting do
  subject { described_class.new(claim:) }

  let(:claim) { build(:submitted_claim).tap { |claim| claim.data.merge!('work_items' => work_items) } }

  before do
    allow(CostCalculator).to receive(:cost).and_return(100.0)
  end

  describe '#table_fields' do
    context 'when a single work item exists' do
      let(:work_items) { [{ 'work_type' => { 'en' => 'travel', 'value' => 'travel' }, 'time_spent' => 20 }] }
      let(:work_item) { instance_double(Assess::V1::WorkItem, work_type: mock_translated('travel'), time_spent: 20) }

      before do
        allow(Assess::BaseViewModel).to receive(:build).and_return([work_item])
      end

      it 'builds the view model' do
        subject.table_fields
        expect(Assess::BaseViewModel).to have_received(:build).with(
          :work_item, claim, 'work_items'
        )
      end

      it 'includes the summed table field row' do
        expect(subject.table_fields).to include(['Travel', '£100.00', '20min'])
      end

      it 'calls the CostCalculator' do
        subject.table_fields

        expect(CostCalculator).to have_received(:cost).with(:work_item, work_item, :caseworker)
      end

      it { expect(subject).to be_any }

      it 'calculates the total_cost' do
        expect(subject.total_cost).to eq('£100.00')
      end
    end

    context 'when multiple work item of diffent types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'travel', 'value' => 'travel' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'waiting', 'value' => 'waiting' }, 'time_spent' => 30 }]
      end

      it 'returns a single table field row' do
        expect(subject.table_fields).to include(['travel', '£100.00', '20min'], ['waiting', '£100.00', '30min'])
      end

      it 'calculates the total_cost' do
        expect(subject.total_cost).to eq('£200.00')
      end
    end

    context 'when waiting and travel work items do not exist' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'preparation', 'value' => 'preparation' }, 'time_spent' => 30 }]
      end

      it 'nothing is returned' do
        expect(subject.table_fields).to eq([])
      end

      it { expect(subject).not_to be_any }
    end

    context 'when multiple work item of the same types exists' do
      let(:work_items) do
        [{ 'work_type' => { 'en' => 'travel', 'value' => 'travel' }, 'time_spent' => 20 },
         { 'work_type' => { 'en' => 'travel', 'value' => 'travel' }, 'time_spent' => 30 }]
      end

      it 'includes a summed table field row' do
        expect(subject.table_fields).to include(['travel', '£200.00', '50min'])
      end
    end
  end
end
