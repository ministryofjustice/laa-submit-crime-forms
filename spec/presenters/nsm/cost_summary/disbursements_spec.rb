require 'rails_helper'

RSpec.describe Nsm::CostSummary::Disbursements do
  subject { described_class.new(disbursements, claim) }

  let(:claim) { instance_double(Claim, assigned_counsel:, in_area:) }
  let(:assigned_counsel) { 'no' }
  let(:in_area) { 'yes' }
  let(:disbursements) do
    [
      instance_double(Disbursement, translated_disbursement_type: 'Car', other_type: nil, total_cost: 100.0,
total_cost_pre_vat: 90.0),
      instance_double(Disbursement, translated_disbursement_type: 'DNA Testing', total_cost: 70.0,
total_cost_pre_vat: 60.0),
      instance_double(Disbursement, translated_disbursement_type: 'Custom', total_cost: 40.0,
total_cost_pre_vat: 30.0),
      instance_double(Disbursement, translated_disbursement_type: 'Car', other_type: nil, total_cost: 90.0,
total_cost_pre_vat: 80.0)
    ]
  end

  describe '#rows' do
    it 'generates letters and calls rows' do
      expect(subject.rows).to eq(
        [[{ classes: 'govuk-table__header', text: 'Car' },
          { classes: 'govuk-table__cell--numeric', text: '£90.00' }],
         [{ classes: 'govuk-table__header', text: 'DNA Testing' },
          { classes: 'govuk-table__cell--numeric', text: '£60.00' }],
         [{ classes: 'govuk-table__header', text: 'Custom' },
          { classes: 'govuk-table__cell--numeric', text: '£30.00' }],
         [{ classes: 'govuk-table__header', text: 'Car' },
          { classes: 'govuk-table__cell--numeric', text: '£80.00' }]]
      )
    end
  end

  describe '#total_cost' do
    it 'delegates to the form' do
      expect(subject.total_cost).to eq(260.00)
    end
  end

  describe '#title' do
    it 'translates without total cost' do
      expect(subject.title).to eq('Disbursements')
    end
  end
end
