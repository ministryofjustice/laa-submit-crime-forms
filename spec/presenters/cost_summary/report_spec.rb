require 'rails_helper'

RSpec.describe CostSummary::Report do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim, work_items: [instance_double(WorkItem)], id: id) }
  let(:id) { SecureRandom.uuid }
  let(:letters_calls) do
    instance_double(CostSummary::LettersCalls, title: l_title, rows: l_rows, total_cost: l_total_cost)
  end
  let(:work_items) do
    instance_double(CostSummary::WorkItems, title: wi_title, rows: wi_rows, total_cost: wi_total_cost)
  end
  let(:wi_title) { 'Work Items Total £75.00' }
  let(:wi_rows) { [double(:row_data)] }
  let(:wi_total_cost) { 75.00 }
  let(:l_title) { 'Letters and Calls Total £100.00' }
  let(:l_rows) { [double(:row_data)] }
  let(:l_total_cost) { 100.00 }

  before do
    allow(CostSummary::WorkItems).to receive(:new).and_return(work_items)
    allow(CostSummary::LettersCalls).to receive(:new).and_return(letters_calls)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(CostSummary::WorkItems).to have_received(:new).with(claim.work_items, claim)
      expect(CostSummary::LettersCalls).to have_received(:new).with(claim)
    end
  end

  describe '#sections' do
    it 'returns an array of data for the Summary list renderer' do
      expect(subject.sections).to eq(
        [
          {
            card: {
              actions: ["<a class=\"govuk-link\" href=\"/applications/#{id}/steps/work_items\">Change</a>"],
              title: 'Work Items Total £75.00'
            },
            rows: [
              {
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Items' },
                value: { classes: 'govuk-summary-list__value-bold', text: 'Total per item' }
              },
              *wi_rows,
              {
                classes: 'govuk-summary-list__row-double-border',
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Total' },
                value: { classes: 'govuk-summary-list__value-bold', text: '£75.00' }
              }
            ]
          },
          {
            card: {
              actions: ["<a class=\"govuk-link\" href=\"/applications/#{id}/steps/letters_calls\">Change</a>"],
              title: 'Letters and Calls Total £100.00'
            },
            rows: [
              {
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Items' },
                value: { classes: 'govuk-summary-list__value-bold', text: 'Total per item' }
              },
              *l_rows,
              {
                classes: 'govuk-summary-list__row-double-border',
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Total' },
                value: { classes: 'govuk-summary-list__value-bold', text: '£100.00' }
              }
            ]
          }
        ]
      )
    end
  end

  describe '#total_cost' do
    it 'sums the cost values' do
      expect(subject.total_cost).to eq('£175.00')
    end
  end
end
