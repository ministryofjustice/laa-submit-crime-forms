require 'rails_helper'

RSpec.describe Assess::V1::AllClaims, type: :view_model do
  subject(:all_claims) do
    described_class.new(laa_reference:, defendants:, firm_office:, created_at:, claim:)
  end

  let(:laa_reference) { '1234567890' }
  let(:defendants) { [{ 'full_name' => 'John Doe', 'main' => true }, 'main' => false, 'full_name' => 'jimbob'] }
  let(:firm_office) { { 'name' => 'Acme Law Firm' } }
  let(:created_at) { Time.zone.today }
  let(:claim) { build(:submitted_claim, id: SecureRandom.uuid) }

  describe '#main_defendant_name' do
    it 'returns the name of the main defendant' do
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('John Doe')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'full_name' => 'John Doe' },
        ]
        summary = described_class.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end

  describe '#firm_name' do
    it 'returns the name of the firm office' do
      expect(all_claims.firm_name).to eq('Acme Law Firm')
    end
  end

  describe '#case_worker_name' do
    context 'when not assigned' do
      it 'returns the unassigned status' do
        expect(all_claims.case_worker_name).to eq('Unassigned')
      end
    end

    context 'when assigned' do
      it 'returns the caseworkers name' do
        assignment = instance_double(Assignment, display_name: 'John Wick')
        allow(claim).to receive(:assignments).and_return([assignment])

        expect(all_claims.case_worker_name).to eq('John Wick')
      end
    end
  end

  describe '#table_fields' do
    it 'returns an array of table fields' do
      expected_fields = [
        { laa_reference: '1234567890', claim_id: claim.id },
        'Acme Law Firm',
        'John Doe',
        { text: I18n.l(Time.zone.today, format: '%-d %b %Y'), sort_value: Time.zone.today.to_fs(:db) },
        'Unassigned'
      ]
      expect(all_claims.table_fields).to eq(expected_fields)
    end
  end
end
