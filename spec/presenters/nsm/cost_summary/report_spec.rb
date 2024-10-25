require 'rails_helper'

RSpec.describe Nsm::CostSummary::Report do
  subject { described_class.new(claim) }

  let(:claim) do
    instance_double(Claim, work_items: [instance_double(WorkItem)], disbursements: disbursements_scope, id: id, totals: totals)
  end
  let(:disbursements_scope) { double(:scope, by_age: [instance_double(Disbursement)]) }
  let(:id) { SecureRandom.uuid }
  let(:letters_calls) do
    instance_double(Nsm::CostSummary::LettersCalls, title: l_title, rows: l_rows, total_cost: l_total_cost,
                    total_cost_cell: 'TOTAL', caption: 'CAPTION', header_row: l_header, footer_row: l_footer)
  end
  let(:work_items) do
    instance_double(Nsm::CostSummary::WorkItems, title: wi_title, rows: wi_rows, total_cost: wi_total_cost,
                    total_cost_inc_vat: wi_total_cost_inc_vat, total_cost_cell: 'TOTAL', caption: 'CAPTION',
                    header_row: wi_header, footer_row: wi_footer)
  end
  let(:disbursements) do
    instance_double(Nsm::CostSummary::Disbursements, title: d_title, rows: d_rows, total_cost: d_total_cost,
                    total_cost_cell: 'TOTAL', caption: 'CAPTION', header_row: d_header, footer_row: d_footer)
  end
  let(:summary) do
    instance_double(Nsm::CheckAnswers::CostSummaryCard, total_gross: 230)
  end
  let(:totals) { { totals: { claimed_total_inc_vat: 230 } } }
  let(:l_title) { 'Letters and Calls' }
  let(:l_rows) { double(:l_row_data) }
  let(:l_total_cost) { 100.00 }
  let(:l_header) { double(:l_header_data) }
  let(:l_footer) { double(:l_footer_data) }
  let(:wi_title) { 'Work Items' }
  let(:wi_rows) { double(:wi_row_data) }
  let(:wi_total_cost) { 75.00 }
  let(:wi_total_cost_inc_vat) { 85.00 }
  let(:wi_header) { double(:wi_header_data) }
  let(:wi_footer) { double(:wi_footer_data) }
  let(:d_title) { 'Disbursements' }
  let(:d_rows) { double(:d_row_data) }
  let(:d_total_cost) { 55.00 }
  let(:d_header) { double(:d_header_data) }
  let(:d_footer) { double(:d_footer_data) }

  before do
    allow(Nsm::CostSummary::WorkItems).to receive(:new).and_return(work_items)
    allow(Nsm::CostSummary::LettersCalls).to receive(:new).and_return(letters_calls)
    allow(Nsm::CostSummary::Disbursements).to receive(:new).and_return(disbursements)
    allow(Nsm::CheckAnswers::CostSummaryCard).to receive(:new).and_return(summary)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Nsm::CostSummary::WorkItems).to have_received(:new).with(claim.work_items, claim)
      expect(Nsm::CostSummary::LettersCalls).to have_received(:new).with(claim)
      expect(Nsm::CostSummary::Disbursements).to have_received(:new).with(disbursements_scope.by_age, claim)
    end
  end

  describe '#sections' do
    it 'returns an array of sections' do
      expect(subject.sections).to be_a Array
    end

    it 'returns a section for work items' do
      expect(subject.sections[0]).to eq(
        {
          card: {
            actions: [
              "<a class=\"govuk-link\" href=\"/non-standard-magistrates/applications/#{id}/steps/work_items\">Change</a>"
            ],
            title: 'Work Items'
          },
          table: {
            head: wi_header,
            rows: [
              wi_rows,
              wi_footer
            ],
            first_cell_is_header: true,
          },
          caption: { classes: 'govuk-visually-hidden', text: 'CAPTION' },
        }
      )
    end

    it 'returns a section for letters and calls' do
      expect(subject.sections[1]).to eq(
        {
          card: {
            actions: [
              "<a class=\"govuk-link\" href=\"/non-standard-magistrates/applications/#{id}/steps/letters_calls\">Change</a>"
            ],
            title: 'Letters and Calls'
          },
           table: {
             head: l_header,
             rows: [
               l_rows,
               l_footer
             ],
             first_cell_is_header: true,
           },
           caption: { classes: 'govuk-visually-hidden', text: 'CAPTION' },
        }
      )
    end

    it 'returns a section for disbursements' do
      expect(subject.sections[2]).to eq(
        {
          card: {
            actions: [
              "<a class=\"govuk-link\" href=\"/non-standard-magistrates/applications/#{id}/steps/disbursements\">Change</a>"
            ],
            title: 'Disbursements'
          },
          table: {
            head: d_header,
            rows: [
              d_rows,
              d_footer
            ],
            first_cell_is_header: true,
          },
          caption: { classes: 'govuk-visually-hidden', text: 'CAPTION' },
        }
      )
    end
  end

  describe '#total_cost' do
    it 'delegates to the summary object' do
      expect(subject.total_cost).to eq('£230.00')
    end
  end
end
