require 'rails_helper'

RSpec.describe CostSummary::WorkItems do
  subject { described_class.new(work_items, claim) }

  let(:claim) { instance_double(Claim, assigned_counsel:, in_area:, date:, firm_office:) }
  let(:firm_office) { build(:firm_office, :valid) }
  let(:assigned_counsel) { 'no' }
  let(:in_area) { 'yes' }
  let(:date) { Date.new(2008, 11, 22) }
  let(:work_items) { [instance_double(WorkItem), instance_double(WorkItem), instance_double(WorkItem)] }
  let(:form_advocacy) { instance_double(Steps::WorkItemForm, work_type: WorkTypes::ADVOCACY, total_cost: 100.0) }
  let(:form_advocacy2) { instance_double(Steps::WorkItemForm, work_type: WorkTypes::ADVOCACY, total_cost: 70.0) }
  let(:form_preparation) { instance_double(Steps::WorkItemForm, work_type: WorkTypes::PREPARATION, total_cost: 40.0) }

  before do
    allow(Steps::WorkItemForm).to receive(:build).with(work_items[0], application: claim).and_return(form_advocacy)
    allow(Steps::WorkItemForm).to receive(:build).with(work_items[1], application: claim).and_return(form_advocacy2)
    allow(Steps::WorkItemForm).to receive(:build).with(work_items[2], application: claim).and_return(form_preparation)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::WorkItemForm).to have_received(:build).with(work_items[0], application: claim)
      expect(Steps::WorkItemForm).to have_received(:build).with(work_items[1], application: claim)
      expect(Steps::WorkItemForm).to have_received(:build).with(work_items[2], application: claim)
    end
  end

  describe '#rows' do
    it 'generates letters and calls rows' do
      expect(subject.rows).to eq(
        [
          {
            key: { classes: 'govuk-summary-list__value-width-50', text: 'Attendance without counsel' },
            value: { text: '£0.00' }
          },
          {
            key: { classes: 'govuk-summary-list__value-width-50', text: 'Preparation' },
            value: { text: '£40.00' }
          },
          {
            key: { classes: 'govuk-summary-list__value-width-50', text: 'Advocacy' },
            value: { text: '£170.00' }
          }
        ]
      )
    end

    context 'when assigned counsel is true' do
      let(:assigned_counsel) { 'yes' }

      it 'includes ATTENDANCE_WITH_COUNSEL in data' do
        row_keys = subject.rows.pluck(:key).pluck(:text)
        expect(row_keys).to eq(
          ['Attendance with counsel', 'Attendance without counsel', 'Preparation', 'Advocacy']
        )
      end
    end

    context 'when in area is false' do
      let(:in_area) { 'no' }

      it 'includes WAITING and TRAVEL in data' do
        row_keys = subject.rows.pluck(:key).pluck(:text)
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
      it 'translates with total cost' do
        expect(subject.title).to eq('Work items total £252.00')
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
      it 'translates with total cost' do
        expect(subject.title).to eq('Work items total £210.00')
      end
    end
  end
end
