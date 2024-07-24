require 'rails_helper'

RSpec.shared_examples 'a correctly ordered results (both ascending and descending)' do |results|
  it { expect(subject).to eq(results) }

  context 'when descending order' do
    let(:sort_direction) { 'descending' }

    it { expect(subject).to eq(results.reverse) }
  end
end

RSpec.describe Sorters::ViewClaimSorter do
  subject { described_class.call(items, sort_by, sort_direction, type).map(&:id) }

  let(:sort_direction) { 'ascending' }

  context 'when sorting disbursements' do
    let(:type) { 'disbursements' }
    let(:items) do
      [
        instance_double(Disbursement, id: 'D1', position: 1, disbursement_date: Date.new(2023, 1, 2),
          total_cost_without_vat: 100),
        instance_double(Disbursement, id: 'D2', position: 2, disbursement_date: Date.new(2023, 1, 4),
          total_cost_without_vat: 200),
        instance_double(Disbursement, id: 'D3', position: 3, disbursement_date: Date.new(2023, 1, 1),
          total_cost_without_vat: 50),
      ]
    end

    context 'when sorting by date' do
      let(:sort_by) { 'date' }

      it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[D3 D1 D2]
    end
  end

  context 'when sorting work items' do
    let(:type) { 'work_items' }
    let(:items) do
      [
        instance_double(WorkItem, id: 'W1', position: 1, completed_on: Date.new(2023, 1, 2),
          total_cost: 100, work_type: 'Research', fee_earner: 'John Doe', time_spent: 2, uplift: 1.5),
        instance_double(WorkItem, id: 'W2', position: 2, completed_on: Date.new(2023, 1, 4),
          total_cost: 200, work_type: 'Drafting', fee_earner: 'Jane Doe', time_spent: 3, uplift: 1.0),
        instance_double(WorkItem, id: 'W3', position: 3, completed_on: Date.new(2023, 1, 1),
          total_cost: 50, work_type: 'Review', fee_earner: 'Jim Beam', time_spent: 1, uplift: 2.0),
      ]
    end

    context 'when sorting by date' do
      let(:sort_by) { 'date' }

      it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[W3 W1 W2]
    end

    context 'when sorting by net_cost' do
      let(:sort_by) { 'net_cost' }

      it_behaves_like 'a correctly ordered results (both ascending and descending)', %w[W3 W1 W2]
    end
  end
end
