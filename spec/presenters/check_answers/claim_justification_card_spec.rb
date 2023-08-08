require 'rails_helper'

RSpec.describe CheckAnswers::ClaimJustificationCard do
  subject { described_class.new(claim) }

  let(:claim) do
    build(:claim, reasons_for_claim:, representation_order_withdrawn_date:, reason_for_claim_other_details:)
  end
  let(:reasons_for_claim) { [ReasonForClaim.new(:enhanced_rates_claimed).to_s, ReasonForClaim.new(:extradition).to_s] }
  let(:representation_order_withdrawn_date) { nil }
  let(:reason_for_claim_other_details) { nil }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim justification')
    end
  end

  describe '#row_data' do
    it 'generates claim justification row' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: 'reasons_for_claim',
            text: 'Enhanced rates claimed<br>Extradition'
          }
        ]
      )
    end

    context 'when no values' do
      let(:reasons_for_claim) { nil }

      it 'renders the missing data tag' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'reasons_for_claim',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            }
          ]
        )
      end
    end

    context 'when field with additional data' do
      let(:reasons_for_claim) { [ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s, ReasonForClaim::OTHER.to_s] }
      let(:representation_order_withdrawn_date) { Date.new(2023, 8, 1) }
      let(:reason_for_claim_other_details) { 'Smme details text' }

      it 'renders the additional field' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'reasons_for_claim',
              text: 'Representation order withdrawn<br>Other'
            },
            {
              head_key: 'representation_order_withdrawn_date',
              text: '01 August 2023'
            },
            {
              head_key: 'reason_for_claim_other_details',
              text: 'Smme details text'
            },
          ]
        )
      end
    end

    context 'when additional data fields are not set' do
      let(:reasons_for_claim) { [ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s, ReasonForClaim::OTHER.to_s] }

      it 'renders the additional field with the missing data tag' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'reasons_for_claim',
              text: 'Representation order withdrawn<br>Other'
            },
            {
              head_key: 'representation_order_withdrawn_date',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'reason_for_claim_other_details',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
          ]
        )
      end
    end
  end
end
