require 'rails_helper'

RSpec.describe CheckAnswers::WorkItemsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :firm_details, work_items:) }
  let(:work_items) do
    [
      build(:work_item, work_type: WorkTypes::ADVOCACY.to_s, time_spent: 180),
      build(:work_item, work_type: WorkTypes::ADVOCACY.to_s, time_spent: 180),
      build(:work_item, work_type: WorkTypes::PREPARATION.to_s, time_spent: 120),
    ]
  end

  describe '#initialize' do
    it 'creates the data instance' do
      expect(Steps::WorkItemForm).to receive(:build).with(work_items[0], application: claim)
      expect(Steps::WorkItemForm).to receive(:build).with(work_items[1], application: claim)
      expect(Steps::WorkItemForm).to receive(:build).with(work_items[2], application: claim)
      subject
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Work items')
    end

    context 'when no work items' do
      let(:work_items) { [] }

      it 'shows title with the missing data tag' do
        expect(subject.title).to eq('Work items <strong class="govuk-tag govuk-tag--red">Incomplete</strong>')
      end
    end
  end

  describe '#row_data' do
    context 'when vat registered' do
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
              text: '£104.30'
            },
            {
              head_key: 'Advocacy',
              text: '£392.52'
            },
            {
              footer: true,
              head_key: 'total',
              text: '£496.82',
            },
            {
              head_key: 'total_inc_vat',
              text: '£596.18'
            }
          ]
        )
      end
    end

    context 'when not vat registered' do
      let(:claim) { build(:claim, :full_firm_details, work_items:) }

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
              text: '£104.30'
            },
            {
              head_key: 'Advocacy',
              text: '£392.52'
            },
            {
              footer: true,
              head_key: 'total',
              text: '£496.82',
            }
          ]
        )
      end
    end
  end
end
