require 'rails_helper'

RSpec.describe Nsm::CostSummary::Disbursements do
  subject { described_class.new(disbursements, claim) }

  let(:claim) { instance_double(Claim, assigned_counsel:, in_area:) }
  let(:assigned_counsel) { 'no' }
  let(:in_area) { 'yes' }
  let(:disbursements) do
    [
      instance_double(Disbursement, disbursement_type: 'car', other_type: nil),
      instance_double(Disbursement, disbursement_type: 'other', other_type: 'dna_testing'),
      instance_double(Disbursement, disbursement_type: 'other', other_type: 'Custom'),
      instance_double(Disbursement, disbursement_type: 'car', other_type: nil)
    ]
  end
  let(:form_car) do
    instance_double(Nsm::Steps::DisbursementCostForm, record: disbursements[0], total_cost: 100.0,
total_cost_pre_vat: 90.0)
  end
  let(:form_dna) do
    instance_double(Nsm::Steps::DisbursementCostForm, record: disbursements[1], total_cost: 70.0,
total_cost_pre_vat: 60.0)
  end
  let(:form_custom) do
    instance_double(Nsm::Steps::DisbursementCostForm, record: disbursements[2], total_cost: 40.0,
total_cost_pre_vat: 30.0)
  end
  let(:form_car2) do
    instance_double(Nsm::Steps::DisbursementCostForm, record: disbursements[3], total_cost: 90.0,
total_cost_pre_vat: 80.0)
  end

  before do
    allow(Nsm::Steps::DisbursementCostForm).to receive(:build).with(disbursements[0],
                                                                    application: claim).and_return(form_car)
    allow(Nsm::Steps::DisbursementCostForm).to receive(:build).with(disbursements[1],
                                                                    application: claim).and_return(form_dna)
    allow(Nsm::Steps::DisbursementCostForm).to receive(:build).with(disbursements[2],
                                                                    application: claim).and_return(form_custom)
    allow(Nsm::Steps::DisbursementCostForm).to receive(:build).with(disbursements[3],
                                                                    application: claim).and_return(form_car2)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Nsm::Steps::DisbursementCostForm).to have_received(:build).with(disbursements[0], application: claim)
      expect(Nsm::Steps::DisbursementCostForm).to have_received(:build).with(disbursements[1], application: claim)
      expect(Nsm::Steps::DisbursementCostForm).to have_received(:build).with(disbursements[2], application: claim)
      expect(Nsm::Steps::DisbursementCostForm).to have_received(:build).with(disbursements[3], application: claim)
    end
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
