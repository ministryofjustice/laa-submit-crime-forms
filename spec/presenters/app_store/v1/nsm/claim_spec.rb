require 'rails_helper'

RSpec.describe AppStore::V1::Nsm::Claim do
  describe '#totals' do
    subject { described_class.new(params.with_indifferent_access).totals }

    let(:params) { { letters_and_calls:, reasons_for_claim:, firm_office:, claim_type:, rep_order_date: } }
    let(:letters_and_calls) { [{ type: 'letters', uplift: 100, count: 1 }, { type: 'calls', uplift: 100, count: 1 }] }
    let(:firm_office) { { vat_registered: 'no' } }
    let(:claim_type) { 'non_standard_magistrate' }
    let(:rep_order_date) { Date.new(2025, 12, 20) }

    context 'when upliftable' do
      let(:reasons_for_claim) { ['enhanced_rates_claimed'] }

      it 'applies uplift' do
        expect(subject.dig(:letters_and_calls, :claimed_total_exc_vat)).to eq(16.36)
      end
    end

    context 'when not upliftable' do
      let(:reasons_for_claim) { ['extradition'] }

      it 'does not apply uplift' do
        expect(subject.dig(:letters_and_calls, :claimed_total_exc_vat)).to eq(8.18)
      end
    end
  end
end
