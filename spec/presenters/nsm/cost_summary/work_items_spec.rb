require 'rails_helper'

RSpec.describe Nsm::CostSummary::WorkItems do
  subject { described_class.new(work_items, claim) }

  let(:claim) do
    instance_double(Claim,
                    assigned_counsel: assigned_counsel,
                    prog_stage_reached?: prog_stage_reached,
                    date: date,
                    firm_office: firm_office)
  end
  let(:firm_office) { build(:firm_office, :valid) }
  let(:assigned_counsel) { 'no' }
  let(:prog_stage_reached) { false }
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
        [
          [
            { classes: 'govuk-table__header', text: 'Attendance without counsel' },
            { text: '0<span class="govuk-visually-hidden"> hours</span>:00' \
                    '<span class="govuk-visually-hidden"> minutes</span>' },
            { classes: 'govuk-table__cell--numeric', text: '£0.00' }
          ],
          [
            { classes: 'govuk-table__header', text: 'Preparation' },
            { text: '3<span class="govuk-visually-hidden"> hours</span>:00' \
                    '<span class="govuk-visually-hidden"> minutes</span>' },
            { classes: 'govuk-table__cell--numeric', text: '£40.00' }
          ],
          [
            { classes: 'govuk-table__header', text: 'Advocacy' },
            { text: '6<span class="govuk-visually-hidden"> hours</span>:00' \
                    '<span class="govuk-visually-hidden"> minutes</span>' },
            { classes: 'govuk-table__cell--numeric', text: '£170.00' }
          ]
        ]
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

    context 'when prog stage reached' do
      let(:prog_stage_reached) { true }

      it 'includes WAITING and TRAVEL in data' do
        row_keys = subject.rows.map(&:first).pluck(:text)
        expect(row_keys).to eq(
          ['Travel', 'Waiting', 'Attendance without counsel', 'Preparation', 'Advocacy']
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
