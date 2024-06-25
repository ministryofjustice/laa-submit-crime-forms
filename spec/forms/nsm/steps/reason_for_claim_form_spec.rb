require 'rails_helper'

RSpec.describe Nsm::Steps::ReasonForClaimForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      reasons_for_claim:,
      representation_order_withdrawn_date:,
      reason_for_claim_other_details:,
    }
  end

  let(:application) do
    instance_double(Claim)
  end

  let(:reasons_for_claim) { [] }
  let(:representation_order_withdrawn_date) { nil }
  let(:reason_for_claim_other_details) { nil }

  describe '#valid?' do
    context 'when no reasons are set' do
      it 'to have errors' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:reasons_for_claim, :blank)).to be(true)
      end
    end

    context 'when no reasons are unknown' do
      let(:reasons_for_claim) { ['unknown'] }

      it 'to have errors' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:reasons_for_claim, :invalid)).to be(true)
      end
    end

    context 'when blank valid is included in the list' do
      let(:reasons_for_claim) { ['', ReasonForClaim::EXTRADITION.to_s] }

      it 'is ignored' do
        expect(subject).to be_valid
      end
    end

    context 'when reasons_for_claim is nil it is igonred' do
      let(:reasons_for_claim) { nil }

      it 'is ignored' do
        expect(subject.reasons_for_claim).to eq([])
      end
    end

    context 'when reason does not require date or text field' do
      [
        ReasonForClaim::CORE_COSTS_EXCEED_HIGHER_LMTS.to_s,
        ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s,
        ReasonForClaim::COUNSEL_OR_AGENT_ASSIGNED.to_s,
        ReasonForClaim::EXTRADITION.to_s,
      ].each do |field|
        context 'and field is set' do
          let(:reasons_for_claim) { [field] }

          it { expect(subject).to be_valid }
        end
      end
    end

    context 'when reason requires a date' do
      let(:reasons_for_claim) { [ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s] }

      context 'and the date is not provided' do
        it 'to have errors' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:representation_order_withdrawn_date, :blank)).to be(true)
        end
      end

      context 'and the date is provided' do
        let(:representation_order_withdrawn_date) { { 1 => 2020, 2 => 3, 3 => 10 } }

        it { expect(subject).to be_valid }

        context 'but it is invalid' do
          let(:representation_order_withdrawn_date) { { 1 => 2020, 2 => 2, 3 => 30 } }

          it 'to have errors' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:representation_order_withdrawn_date, :invalid)).to be(true)
          end
        end
      end
    end

    context 'when reason requires a text field' do
      let(:reasons_for_claim) { [ReasonForClaim::OTHER.to_s] }

      context 'and the text field is not provided' do
        it 'to have errors' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:reason_for_claim_other_details, :blank)).to be(true)
        end
      end

      context 'and the text field is provided' do
        let(:reason_for_claim_other_details) { 'some text' }

        it { expect(subject).to be_valid }
      end
    end
  end

  describe '#save' do
    context 'when uplifts have previously been applied' do
      let(:application) do
        create(:claim, letters_uplift: 10, calls_uplift: 50, work_items: [build(:work_item, :with_uplift)])
      end

      context 'and enhanced rates are no longer claimed' do
        let(:reasons_for_claim) { [ReasonForClaim::EXTRADITION.to_s] }

        before { subject.save }

        it 'removes all now-redundant uplift data' do
          expect(application.reload).to have_attributes(letters_uplift: nil, calls_uplift: nil)
          expect(application.work_items.first).to have_attributes(uplift: nil)
        end
      end
    end
  end
end
