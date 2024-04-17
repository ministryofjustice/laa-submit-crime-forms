require 'rails_helper'

RSpec.describe CostCalculator do
  subject { described_class.cost(type, object, vat) }

  let(:object) { create(:claim, :travel_and_waiting) }
  let(:vat) { true }
  let(:pricing) { instance_double(Pricing, '[]': price, vat: vat_rate) }
  let(:price) { 0.45 }
  let(:vat_rate) { 0.2 }

  context 'when type is unknown' do
    let(:type) { :unknown }

    it { expect(subject).to be_nil }
  end

  context 'when type is disbursement_total' do
    before do
      allow(Pricing).to receive(:for).and_return(pricing)
    end

    let(:type) { :disbursement_total }
    let(:object) { create(:claim, :mixed_vat_disbursement) }

    context 'when vat is true' do
      it 'calculates the sum total cost for each travel and waiting work item with vat' do
        expect(subject).to eq(198)
      end

      context 'when raw vat calculation returns a result that involves fractions of pennies' do
        before do
          object.disbursements.first.update(total_cost_without_vat: 37.79, apply_vat: 'true')
          object.disbursements.last.update(total_cost_without_vat: 50.0, apply_vat: 'false')
        end

        it 'calculates the sum total cost for each travel and waiting work item with vat' do
          # 37.79 * 1.2 = 45.35 (rounded)
          # 45.35 + 50 = 95.35
          expect(subject).to eq(95.35)
        end
      end
    end

    context 'when vat is false' do
      let(:vat) { false }

      it 'calculates the sum total cost for each travel and waiting work item' do
        expect(subject).to eq(180)
      end
    end
  end

  context 'when type is travel_and_waiting_total' do
    before do
      allow(Pricing).to receive(:for).and_return(pricing)
    end

    let(:type) { :travel_and_waiting_total }

    context 'when vat is true' do
      it 'calculates the sum total cost for each travel and waiting work item with vat' do
        expect(subject).to eq(1.98)
      end

      context 'when raw vat calculation returns a result that involves fractions of pennies' do
        let(:object) { create(:claim, work_items:) }
        let(:work_items) do
          [
            build(:work_item, time_spent: 49, uplift: 10, work_type: 'travel'),
            build(:work_item, time_spent: 60, uplift: 0, work_type: 'waiting'),
          ]
        end

        let(:price) { 7.55 }

        it 'calculates the sum total cost for each travel and waiting work item with vat' do
          # First work item cost without VAT: 7.55 * 49/60 = 6.165833333
          # First work item cost with uplift: 6.165833333 * 1.1 = 6.78241333
          # First work item cost with VAT = 6.78241333 * 1.2 = 8.1389
          # Second work item cost without VAT: 7.55
          # Second work item cost with VAT: 7.55 * 1.2 = 9.06
          # Total (unrounded): 8.1389 + 9.06 = 17.1989
          # Total (rounded): 17.20
          expect(subject).to eq(17.20)
        end
      end
    end

    context 'when vat is false' do
      let(:vat) { false }

      it 'calculates the sum total cost for each travel and waiting work item' do
        expect(subject).to eq(1.65)
      end
    end
  end
end
