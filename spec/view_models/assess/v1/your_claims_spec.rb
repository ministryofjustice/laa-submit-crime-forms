require 'rails_helper'

RSpec.describe Assess::V1::YourClaims, type: :view_model do
  subject(:your_claims) do
    described_class.new(laa_reference:, defendants:, firm_office:, created_at:, claim:, risk:)
  end

  let(:laa_reference) { '1234567890' }
  let(:defendants) { [{ 'full_name' => 'John Doe', 'main' => true }, 'main' => false, 'full_name' => 'jimbob'] }
  let(:firm_office) { { 'name' => 'Acme Law Firm' } }
  let(:created_at) { Time.zone.yesterday }
  let(:claim) { instance_double(SubmittedClaim, id: 1) }
  let(:risk) { 'low' }

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
      expect(your_claims.firm_name).to eq('Acme Law Firm')
    end
  end

  describe '#risk_sort' do
    context 'when risk is high' do
      it 'returns a hash with text "high" and sort value 1' do
        subject.risk = 'high'
        expect(subject.risk_sort).to eq(1)
      end
    end

    context 'when risk is medium' do
      it 'returns a hash with text "medium" and sort value 2' do
        subject.risk = 'medium'
        expect(subject.risk_sort).to eq(2)
      end
    end

    context 'when risk is low' do
      it 'returns a hash with text "low" and sort value 3' do
        subject.risk = 'low'
        expect(subject.risk_sort).to eq(3)
      end
    end

    context 'when risk is invalid' do
      it 'returns nil' do
        subject.risk = nil
        expect(subject.risk_sort).to be_nil
      end
    end
  end

  describe 'date_created' do
    before do
      subject.created_at = DateTime.new(2023, 11, 21, 17, 17, 43)
    end

    it 'date_created_str -> formats the created_at date' do
      expect(subject.date_created_str).to eq('21 Nov 2023')
    end

    it 'date_created_sort -> returns value for sort' do
      expect(subject.date_created_sort).to eq('2023-11-21')
    end
  end
end
