require 'rails_helper'

RSpec.describe CostSummary::Report do
  subject { described_class.new(claim) }

  let(:claim) do
    instance_double(Claim, work_items: [instance_double(WorkItem)], disbursements: disbursements_scope, id: id)
  end
  let(:disbursements_scope) { double(:scope, by_age: [instance_double(Disbursement)]) }
  let(:id) { SecureRandom.uuid }
  let(:letters_calls) do
    instance_double(CostSummary::LettersCalls, title: l_title, rows: l_rows, total_cost: l_total_cost, total_cost_inc_vat: l_total_cost_inc_vat)
  end
  let(:work_items) do
    instance_double(CostSummary::WorkItems, title: wi_title, rows: wi_rows, total_cost: wi_total_cost, total_cost_inc_vat: wi_total_cost_inc_vat)
  end
  let(:disbursements) do
    instance_double(CostSummary::Disbursements, title: d_title, rows: d_rows, total_cost: d_total_cost, total_cost_inc_vat: d_total_cost_inc_vat)
  end
  let(:l_title) { 'Letters and Calls Total £100.00' }
  let(:l_rows) { [double(:row_data)] }
  let(:l_total_cost) { 100.00 }
  let(:l_total_cost_inc_vat) { 120.00 }
  let(:wi_title) { 'Work Items Total £75.00' }
  let(:wi_rows) { [double(:row_data)] }
  let(:wi_total_cost) { 75.00 }
  let(:wi_total_cost_inc_vat) { 85.00 }
  let(:d_title) { 'Disbursements Total £55.00' }
  let(:d_rows) { [double(:row_data)] }
  let(:d_total_cost) { 55.00 }
  let(:d_total_cost_inc_vat) { 65.00 }

  before do
    allow(CostSummary::WorkItems).to receive(:new).and_return(work_items)
    allow(CostSummary::LettersCalls).to receive(:new).and_return(letters_calls)
    allow(CostSummary::Disbursements).to receive(:new).and_return(disbursements)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(CostSummary::WorkItems).to have_received(:new).with(claim.work_items, claim)
      expect(CostSummary::LettersCalls).to have_received(:new).with(claim)
      expect(CostSummary::Disbursements).to have_received(:new).with(disbursements_scope.by_age, claim)
    end
  end

  describe '#sections' do
    # rubocop:disable RSpec/ExampleLength
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
              },
              {
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Total (including VAT)' },
                value: { classes: 'govuk-summary-list__value-bold', text: '£85.00' }
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
              },
              {
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Total (including VAT)' },
                value: { classes: 'govuk-summary-list__value-bold', text: '£120.00' }
              }
            ]
          },
          {
            card: {
              actions: ["<a class=\"govuk-link\" href=\"/applications/#{id}/steps/disbursements\">Change</a>"],
              title: 'Disbursements Total £55.00'
            },
            rows: [
              {
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Items' },
                value: { classes: 'govuk-summary-list__value-bold', text: 'Total per item' }
              },
              *d_rows,
              {
                classes: 'govuk-summary-list__row-double-border',
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Total' },
                value: { classes: 'govuk-summary-list__value-bold', text: '£55.00' }
              },
              {
                key: { classes: 'govuk-summary-list__value-width-50', text: 'Total (including VAT)' },
                value: { classes: 'govuk-summary-list__value-bold', text: '£65.00' }
              }
            ]
          }
        ]
      )
    end
    # rubocop:enable RSpec/ExampleLength
  end

  describe '#total_cost' do
    it 'sums the cost values' do
      expect(subject.total_cost).to eq('£230.00')
    end

    context 'when a section has a nil total cost' do
      let(:l_total_cost) { nil }

      it 'does not raise an error' do
        expect { subject.total_cost }.not_to raise_error
        expect(subject.total_cost).to eq('£130.00')
      end
    end
  end
end
