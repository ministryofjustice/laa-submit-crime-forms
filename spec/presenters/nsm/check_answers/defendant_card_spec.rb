require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::DefendantCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim, claim_type:, defendants:) }
  let(:defendants) { [] }
  let(:main_defendant) { { main: true, full_name: main_defendant_name, maat: main_defendant_maat } }
  let(:first_additional_defendant) do
    { main: false, full_name: first_additional_defendant_name, maat: first_additional_defendant_maat }
  end
  let(:second_additional_defendant) do
    { main: false, full_name: second_additional_defendant_name, maat: second_additional_defendant_maat }
  end

  let(:main_defendant_name) { 'Tim Roy' }
  let(:main_defendant_maat) { '123ABC' }
  let(:first_additional_defendant_name) { 'James Brown' }
  let(:first_additional_defendant_maat) { '456EFG' }
  let(:second_additional_defendant_name) { 'Timmy Turner' }
  let(:second_additional_defendant_maat) { '789HIJ' }

  let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE.to_s }

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(claim).to have_received(:defendants)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Defendant details')
    end
  end

  describe '#row_data' do
    context '1 main defendant and 2 additional defendants' do
      let(:defendants) { [main_defendant, first_additional_defendant, second_additional_defendant] }

      it 'generates full name and maat ref for 1 main defendant and 2 additional defendants' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'main_defendant_full_name',
              text: 'Tim Roy',
              head_opts: { count: 1 },
            },
            {
              head_key: 'main_defendant_maat',
              text: '123ABC',
              head_opts: { count: 1 },
            },
            {
              head_key: 'additional_defendant_full_name',
              text: 'James Brown',
              head_opts: { count: 1 }
            },
            {
              head_key: 'additional_defendant_maat',
              text: '456EFG',
              head_opts: { count: 1 }
            },
            {
              head_key: 'additional_defendant_full_name',
              text: 'Timmy Turner',
              head_opts: { count: 2 }
            },
            {
              head_key: 'additional_defendant_maat',
              text: '789HIJ',
              head_opts: { count: 2 }
            }
          ]
        )
      end

      context 'when claim_type is BREACH_OF_INJUNCTION' do
        let(:defendants) { [main_defendant, first_additional_defendant, second_additional_defendant] }
        let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

        it 'does not include maat data' do
          expect(subject.row_data).to eq(
            [
              {
                head_key: 'main_defendant_full_name',
                text: 'Tim Roy',
                head_opts: { count: 1 },
              },
              {
                head_key: 'additional_defendant_full_name',
                text: 'James Brown',
                head_opts: { count: 1 }
              },
              {
                head_key: 'additional_defendant_full_name',
                text: 'Timmy Turner',
                head_opts: { count: 2 }
              },
            ]
          )
        end
      end
    end

    context 'no defendants' do
      let(:defendants) { [] }

      it 'generates full name and maat for 1 main defendant' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'main_defendant_full_name',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>',
              head_opts: { count: 1 },
            },
            {
              head_key: 'main_defendant_maat',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>',
              head_opts: { count: 1 },
            }
          ]
        )
      end
    end

    context '1 main defendant' do
      let(:defendants) { [main_defendant] }

      it 'generates full name and maat for 1 main defendant' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'main_defendant_full_name',
              text: 'Tim Roy',
              head_opts: { count: 1 },
            },
            {
              head_key: 'main_defendant_maat',
              text: '123ABC',
              head_opts: { count: 1 },
            }
          ]
        )
      end

      context 'when values are missing' do
        let(:main_defendant_maat) { nil }

        it 'marks them as missing' do
          expect(subject.row_data).to eq(
            [
              {
                head_key: 'main_defendant_full_name',
                text: 'Tim Roy',
                head_opts: { count: 1 },
              },
              {
                head_key: 'main_defendant_maat',
                text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>',
                head_opts: { count: 1 },
              }
            ]
          )
        end
      end
    end
  end
end
