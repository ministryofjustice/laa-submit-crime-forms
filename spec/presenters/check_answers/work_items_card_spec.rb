require 'rails_helper'

RSpec.describe CheckAnswers::WorkItemsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim, work_items:, assigned_counsel:, in_area:) }
  let(:work_items) { [instance_double(WorkItem), instance_double(WorkItem), instance_double(WorkItem)] }
  let(:form_advocacy) { instance_double(Steps::WorkItemForm, work_type: WorkTypes::ADVOCACY, total_cost: 100.0) }
  let(:form_advocacy2) { instance_double(Steps::WorkItemForm, work_type: WorkTypes::ADVOCACY, total_cost: 70.0) }
  let(:form_preparation) { instance_double(Steps::WorkItemForm, work_type: WorkTypes::PREPARATION, total_cost: 40.0) }
  let(:assigned_counsel) { 'no' }
  let(:in_area) { 'yes' }

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

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Work items')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#row_data' do
    it 'generates work items rows' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: 'items',
            text: '<strong>Total per item</strong>'
          },
          {
            head_key: 'Attendance without counsel',
            text: '£0.00'
          },
          {
            head_key: 'Preparation',
            text: '£40.00'
          },
          {
            head_key: 'Advocacy',
            text: '£170.00'
          }
        ]
      )
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
