require 'rails_helper'

RSpec.describe Assess::V1::Disbursement do
  let(:disbursement) { described_class.new({}) }

  describe '#provider_requested_total_cost_without_vat' do
    it 'returns the value from the first event if present' do
      allow(disbursement).to receive(:value_from_first_event).with('total_cost_without_vat').and_return(100)
      expect(disbursement.provider_requested_total_cost_without_vat).to eq(100)
    end

    it 'returns the total_cost_without_vat if no value from the first event' do
      allow(disbursement).to receive(:value_from_first_event).with('total_cost_without_vat').and_return(nil)
      disbursement.total_cost_without_vat = 200
      expect(disbursement.provider_requested_total_cost_without_vat).to eq(200)
    end
  end

  describe '#provider_requested_total_cost' do
    it 'returns the cost calculated by the CostCalculator' do
      allow(CostCalculator).to receive(:cost).with(:disbursement, disbursement).and_return(300)
      expect(disbursement.provider_requested_total_cost).to eq(300)
    end
  end

  describe '#caseworker_total_cost' do
    it 'returns 0 if total_cost_without_vat is zero' do
      disbursement.total_cost_without_vat = 0
      expect(disbursement.caseworker_total_cost).to eq(0)
    end

    it 'returns the provider_requested_total_cost if total_cost_without_vat is not zero' do
      disbursement.total_cost_without_vat = 100
      allow(disbursement).to receive(:provider_requested_total_cost).and_return(400)
      expect(disbursement.caseworker_total_cost).to eq(400)
    end
  end

  describe '#disbursement_fields' do
    it 'returns a hash with the correct fields if no miles' do
      allow(disbursement).to receive_messages(disbursement_date: Date.new(2022, 1, 1), type_name: 'type',
                                              details: 'details', prior_authority: 'prior_authority',
                                              vat_rate: 0.2, apply_vat: 'true')
      allow(CostCalculator).to receive(:cost).with(:disbursement, disbursement).and_return(100)

      expected_fields = {
        date: '01 Jan 2022',
        type: 'Type',
        details: 'Details',
        prior_authority: 'Prior_authority',
        vat: '20%',
        total: '£100.00'
      }

      expect(disbursement.disbursement_fields).to eq(expected_fields)
    end

    it 'returns a hash with the correct fields if miles present' do
      allow(disbursement).to receive_messages(disbursement_date: Date.new(2022, 1, 1), type_name: 'type',
                                              details: 'details', prior_authority: 'prior_authority',
                                              vat_rate: 0.2, miles: 10, apply_vat: 'true')
      allow(CostCalculator).to receive(:cost).with(:disbursement, disbursement).and_return(100)

      expected_fields = {
        date: '01 Jan 2022',
        type: 'Type',
        details: 'Details',
        prior_authority: 'Prior_authority',
        vat: '20%',
        miles: '10',
        total: '£100.00'
      }

      expect(disbursement.disbursement_fields).to eq(expected_fields)
    end

    it 'returns a hash with the correct fields if apply vat is false' do
      allow(disbursement).to receive_messages(disbursement_date: Date.new(2022, 1, 1), type_name: 'type',
                                              details: 'details', prior_authority: 'prior_authority',
                                              vat_rate: 0.2, apply_vat: 'false')
      allow(CostCalculator).to receive(:cost).with(:disbursement, disbursement).and_return(100)

      expected_fields = {
        date: '01 Jan 2022',
        type: 'Type',
        details: 'Details',
        prior_authority: 'Prior_authority',
        total: '£100.00'
      }

      expect(disbursement.disbursement_fields).to eq(expected_fields)
    end
  end

  describe 'table_fields' do
    before do
      allow(CostCalculator).to receive(:cost).and_return(10.0)
    end

    it 'returns the fields for the table display if no adjustments' do
      allow(disbursement).to receive_messages(disbursement_type: 'Car')
      disbursement.adjustments = []
      expect(disbursement.table_fields).to eq(['Car', '£10.00', '0%', ''])
    end

    it 'returns an array with the correct fields if there are adjustments' do
      allow(disbursement).to receive_messages(type_name: 'type', provider_requested_total_cost: 100,
                                              caseworker_total_cost: 200)
      disbursement.adjustments = [1]
      expected_fields = ['type', '£100.00', '0%', '£200.00']
      expect(disbursement.table_fields).to eq(expected_fields)
    end

    it 'returns the formatted vat rate when apply_vat is true' do
      allow(disbursement).to receive_messages(type_name: 'type', provider_requested_total_cost: 100,
                                              caseworker_total_cost: 200, apply_vat: 'true', format_vat_rate: '20%')
      expected_fields = ['type', '£100.00', '20%', '']
      expect(disbursement.table_fields).to eq(expected_fields)
    end
  end
end
