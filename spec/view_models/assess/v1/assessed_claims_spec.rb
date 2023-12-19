require 'rails_helper'

RSpec.describe Assess::V1::AssessedClaims, type: :view_model do
  subject(:assessed_claims) do
    described_class.new(laa_reference:, defendants:, firm_office:, updated_at:, claim:, state:)
  end

  let(:laa_reference) { '1234567890' }
  let(:defendants) { [{ 'full_name' => 'John Doe', 'main' => true }, 'main' => false, 'full_name' => 'jimbob'] }
  let(:firm_office) { { 'name' => 'Acme Law Firm' } }
  let(:updated_at) { Time.zone.yesterday }
  let(:claim) { instance_double(SubmittedClaim, id: 1, events: events) }
  let(:events) { double(where: double(order: [instance_double(Event, primary_user:)])) }
  let(:primary_user) { instance_double(User, display_name: 'Jim Bob') }
  let(:state) { 'granted' }

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
      expect(assessed_claims.firm_name).to eq('Acme Law Firm')
    end
  end

  describe '#case_worker_name' do
    it 'returns user anme from the last Desision Event' do
      expect(assessed_claims.case_worker_name).to eq('Jim Bob')
    end

    context 'when no decision event' do
      let(:events) { double(where: double(order: [])) }

      it 'returns nil' do
        expect(assessed_claims.case_worker_name).to eq('')
      end
    end
  end

  describe '#status' do
    it 'returns the correct color for the given item' do
      expect(subject.status('granted')).to eq({ colour: 'green', sort_value: 1, text: 'granted' })
      expect(subject.status('part_grant')).to eq({ colour: 'blue', text: 'part_grant', sort_value: 2 })
      expect(subject.status('rejected')).to eq({ colour: 'red', text: 'rejected', sort_value: 3 })
      expect(subject.status('invalid')).to eq({ colour: 'grey', text: 'invalid', sort_value: 4 })
    end
  end

  describe '#table_fields' do
    it 'returns an array of table fields' do
      expected_fields = [
        { laa_reference: '1234567890', claim_id: 1 },
        'Acme Law Firm',
        'John Doe',
        { text: I18n.l(Time.zone.yesterday, format: '%-d %b %Y'), sort_value: Time.zone.yesterday.to_fs(:db) },
        'Jim Bob',
        { colour: 'green', sort_value: 1, text: 'granted' }
      ]
      expect(assessed_claims.table_fields).to eq(expected_fields)
    end
  end
end
