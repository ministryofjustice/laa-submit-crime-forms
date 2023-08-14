require 'rails_helper'

RSpec.describe CheckAnswers::OtherInfoCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, is_other_info:, other_info:, concluded:, conclusion:) }
  let(:other_info) { 'Line 1' }
  let(:is_other_info) { 'yes' }
  let(:concluded) { 'no' }
  let(:conclusion) { nil }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Other relevant information')
    end
  end

  describe '#row_data' do
    context '1 line of information' do
      it 'generates a row with one line of relevant information' do
        expect(subject.row_data).to eq(
          [
            
            {
              head_key: 'is_other_info',
              text: 'Yes'
            },
            {
              head_key: 'other_info',
              text: 'Line 1'
            },
            {
              head_key: 'concluded',
              text: 'No'
            }
          ]
        )
      end
    end

    context 'generates a row with 2 lines of relevant information' do
      let(:other_info) { "Line 1\nLine 2" }

      it 'generates case detail rows with 1 line of address' do
        expect(filter_rows(subject.row_data, 'other_info')).to eq(
          [
            {
              head_key: 'other_info',
              text: 'Line 1<br>Line 2'
            }
          ]
        )
      end
    end

    context 'no information' do
      let(:claim) { build(:claim) }

      it 'generates a row with one line of relevant information' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'is_other_info',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'concluded',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            }
          ]
        )
      end
    end

    context 'no other information' do
      let(:is_other_info) { 'no' }

      it 'shows both choice options as No' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'is_other_info',
              text: 'No'
            },
            {
              head_key: 'concluded',
              text: 'No'
            }
          ]
        )
      end
    end

    context 'with conclusion' do
      let(:concluded) { 'yes' }
      let(:conclusion) { 'I was late' }

      it 'generates a row with one line of relevant information' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'is_other_info',
              text: 'Yes'
            },
            {
              head_key: 'other_info',
              text: 'Line 1'
            },
            {
              head_key: 'concluded',
              text: 'Yes'
            },
            {
              head_key: 'conclusion',
              text: 'I was late'
            }
          ]
        )
      end
    end

    context 'missing conclusion' do
      let(:concluded) { 'yes' }

      it 'generates a row with one line of relevant information' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'is_other_info',
              text: 'Yes'
            },
            {
              head_key: 'other_info',
              text: 'Line 1'
            },
            {
              head_key: 'concluded',
              text: 'Yes'
            },
            {
              head_key: 'conclusion',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            }
          ]
        )
      end
    end
  end
end
