require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::WorkItemsCard do
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
      expect(Nsm::Steps::WorkItemForm).to receive(:build).with(work_items[0], application: claim)
      expect(Nsm::Steps::WorkItemForm).to receive(:build).with(work_items[1], application: claim)
      expect(Nsm::Steps::WorkItemForm).to receive(:build).with(work_items[2], application: claim)
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
              head_key: 'attendance_without_counsel',
              text: '£0.00'
            },
            {
              head_key: 'preparation',
              text: '£104.30'
            },
            {
              head_key: 'advocacy',
              text: '£392.52'
            },
            {
              footer: true,
              head_key: 'total',
              text: '<strong>£496.82</strong>',
            },
            {
              head_key: 'total_inc_vat',
              text: '<strong>£596.18</strong>'
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
              head_key: 'attendance_without_counsel',
              text: '£0.00'
            },
            {
              head_key: 'preparation',
              text: '£104.30'
            },
            {
              head_key: 'advocacy',
              text: '£392.52'
            },
            {
              footer: true,
              head_key: 'total',
              text: '<strong>£496.82</strong>',
            }
          ]
        )
      end
    end
  end
end
