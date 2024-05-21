require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::LettersCallsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :firm_details, letters:, calls:, letters_uplift:, calls_uplift:, reasons_for_claim:) }

  let(:letters) { 20 }
  let(:calls) { 5 }
  let(:letters_uplift) { 20 }
  let(:calls_uplift) { 15 }
  let(:reasons_for_claim) { [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s] }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Letters and phone calls')
    end
  end

  describe '#row_data' do
    context 'when claim justification includes enhanced rate' do
      it 'generates letters and calls rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'items',
              text: '<strong>Total per item</strong>'
            },
            {
              head_key: 'letters',
              text: 20
            },
            {
              head_key: 'letters_uplift',
              text: '20%'
            },
            {
              head_key: 'letters_payment',
              text: '£98.16'
            },
            {
              head_key: 'calls',
              text: 5
            },
            {
              head_key: 'calls_uplift',
              text: '15%'
            },
            {
              head_key: 'calls_payment',
              text: '£23.52'
            },
            {
              head_key: 'total',
              text: '<strong>£121.68</strong>',
              footer: true
            },
            {
              head_key: 'total_inc_vat',
              text: '<strong>£146.01</strong>'
            }
          ]
        )
      end
    end

    context 'when claim justification does not include enhanced rate' do
      let(:reasons_for_claim) { [ReasonForClaim::COUNCEL_OR_AGENT_ASSIGNED.to_s] }

      it 'does not include the uplift rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'items',
              text: '<strong>Total per item</strong>'
            },
            {
              head_key: 'letters',
              text: 20
            },
            {
              head_key: 'letters_payment',
              text: '£81.80'
            },
            {
              head_key: 'calls',
              text: 5
            },
            {
              head_key: 'calls_payment',
              text: '£20.45'
            },
            {
              head_key: 'total',
              text: '<strong>£102.25</strong>',
              footer: true
            },
            {
              head_key: 'total_inc_vat',
              text: '<strong>£122.70</strong>'
            }
          ]
        )
      end
    end

    context 'no letters or calls requested' do
      let(:claim) { build(:claim, :full_firm_details, reasons_for_claim:) }

      it 'generates letters and calls rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'items',
              text: '<strong>Total per item</strong>'
            },
            {
              head_key: 'letters',
              text: 0
            },
            {
              head_key: 'letters_uplift',
              text: '0%'
            },
            {
              head_key: 'letters_payment',
              text: '£0.00'
            },
            {
              head_key: 'calls',
              text: 0
            },
            {
              head_key: 'calls_uplift',
              text: '0%'
            },
            {
              head_key: 'calls_payment',
              text: '£0.00'
            },
            {
              head_key: 'total',
              text: '<strong>£0.00</strong>',
              footer: true
            }
          ]
        )
      end
    end
  end
end
