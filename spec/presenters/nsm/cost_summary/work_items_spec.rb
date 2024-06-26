require 'rails_helper'

RSpec.describe Nsm::CostSummary::WorkItems do
  subject { described_class.new(work_items, claim) }

  let(:claim) { instance_double(Claim, assigned_counsel:, in_area:, date:, firm_office:) }
  let(:firm_office) { build(:firm_office, :valid) }
  let(:assigned_counsel) { 'no' }
  let(:in_area) { 'yes' }
  let(:date) { Date.new(2008, 11, 22) }
  let(:work_items) do
    [
      instance_double(WorkItem, work_type: WorkTypes::ADVOCACY.to_s, total_cost: 100.0, time_spent: 180),
      instance_double(WorkItem, work_type: WorkTypes::ADVOCACY.to_s, total_cost: 70.0, time_spent: 180),
      instance_double(WorkItem, work_type: WorkTypes::PREPARATION.to_s, total_cost: 40.0, time_spent: 180)
    ]
  end

  describe '#rows' do
    it 'generates letters and calls rows' do
      expect(subject.rows).to eq(
        [[{ classes: 'govuk-table__header', text: 'Attendance without counsel' },
          { text: '0 hours 0 minutes' },
          { classes: 'govuk-table__cell--numeric', text: '£0.00' }],
         [{ classes: 'govuk-table__header', text: 'Preparation' },
          { text: '3 hours 0 minutes' },
          { classes: 'govuk-table__cell--numeric', text: '£40.00' }],
         [{ classes: 'govuk-table__header', text: 'Advocacy' },
          { text: '6 hours 0 minutes' },
          { classes: 'govuk-table__cell--numeric', text: '£170.00' }]]
      )
    end

    context 'when assigned counsel is true' do
      let(:assigned_counsel) { 'yes' }

      it 'includes ATTENDANCE_WITH_COUNSEL in data' do
        row_keys = subject.rows.map(&:first).pluck(:text)
        expect(row_keys).to eq(
          ['Attendance with counsel', 'Attendance without counsel', 'Preparation', 'Advocacy']
        )
      end
    end

    context 'when in area is false' do
      let(:in_area) { 'no' }

      it 'includes WAITING and TRAVEL in data' do
        row_keys = subject.rows.map(&:first).pluck(:text)
        expect(row_keys).to eq(
          ['Attendance without counsel', 'Preparation', 'Advocacy', 'Travel', 'Waiting']
        )
      end
    end
  end

  context 'vat registered' do
    describe '#total_cost' do
      it 'delegates to the form' do
        expect(subject.total_cost).to eq(210.00)
      end
    end

    describe '#total_cost_inc_vat' do
      it 'delegates to the form' do
        expect(subject.total_cost_inc_vat).to eq(252.00)
      end
    end

    describe '#title' do
      it 'translates without total cost' do
        expect(subject.title).to eq('Work items')
      end
    end
  end

  context 'not vat registered' do
    let(:firm_office) { build(:firm_office, :full) }

    describe '#total_cost' do
      it 'delegates to the form' do
        expect(subject.total_cost).to eq(210.00)
      end
    end

    describe '#total_cost_inc_vat' do
      it 'delegates to the form' do
        expect(subject.total_cost_inc_vat).to eq(0)
      end
    end

    describe '#title' do
      it 'translates without total cost' do
        expect(subject.title).to eq('Work items')
      end
    end
  end
end
