require 'rails_helper'

RSpec.describe Nsm::CostSummary::Disbursements do
  subject { described_class.new(disbursements, claim) }

  let(:claim) do
    instance_double(Claim, assigned_counsel: assigned_counsel, prog_stage_reached?: prog_stage_reached, totals: totals)
  end
  let(:assigned_counsel) { 'no' }
  let(:prog_stage_reached) { false }
  let(:disbursements) do
    [
      instance_double(Disbursement, translated_disbursement_type: 'Car', other_type: nil, total_cost: 100.0,
total_cost_pre_vat: 90.0, vat: 10.0),
      instance_double(Disbursement, translated_disbursement_type: 'DNA Testing', total_cost: 70.0,
total_cost_pre_vat: 60.0, vat: 10.0),
      instance_double(Disbursement, translated_disbursement_type: 'Custom', total_cost: 40.0,
total_cost_pre_vat: 30.0, vat: 10.0),
      instance_double(Disbursement, translated_disbursement_type: 'Car', other_type: nil, total_cost: 90.0,
total_cost_pre_vat: 80.0, vat: 10.0)
    ]
  end

  let(:totals) { { cost_summary: { disbursements: { claimed_total_exc_vat: 260.0, claimed_total_inc_vat: 300.0 } } } }

  describe '#rows' do
    it 'generates disbursement rows' do
      expect(subject.rows).to eq(
        [[{ classes: 'govuk-table__header', text: 'Car' },
          { classes: 'govuk-table__cell--numeric', text: '£90.00' },
          { classes: 'govuk-table__cell--numeric', text: '£10.00' },
          { classes: 'govuk-table__cell--numeric', text: '£100.00' }],
         [{ classes: 'govuk-table__header', text: 'DNA Testing' },
          { classes: 'govuk-table__cell--numeric', text: '£60.00' },
          { classes: 'govuk-table__cell--numeric', text: '£10.00' },
          { classes: 'govuk-table__cell--numeric', text: '£70.00' }],
         [{ classes: 'govuk-table__header', text: 'Custom' },
          { classes: 'govuk-table__cell--numeric', text: '£30.00' },
          { classes: 'govuk-table__cell--numeric', text: '£10.00' },
          { classes: 'govuk-table__cell--numeric', text: '£40.00' }],
         [{ classes: 'govuk-table__header', text: 'Car' },
          { classes: 'govuk-table__cell--numeric', text: '£80.00' },
          { classes: 'govuk-table__cell--numeric', text: '£10.00' },
          { classes: 'govuk-table__cell--numeric', text: '£90.00' }]]
      )
    end
  end

  describe '#total_cost' do
    it 'delegates to the form' do
      expect(subject.total_cost).to eq(300.00)
    end
  end

  describe '#net_cost' do
    it 'delegates to the form' do
      expect(subject.net_cost).to eq(260.00)
    end
  end

  describe '#title' do
    it 'translates without total cost' do
      expect(subject.title).to eq('Disbursements')
    end
  end
end
