require 'rails_helper'

RSpec.describe CheckAnswers::LettersCallsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:letters_calls_form) do
    instance_double(Steps::LettersCallsForm, letters:, calls:, letters_uplift:, letters_after_uplift:, calls_uplift:, calls_after_uplift:, total_cost:)
  end

  let(:letters) { 20 }
  let(:calls) { 5 }
  let(:letters_uplift) { 20 }
  let(:calls_uplift) { 15 }
  let(:letters_after_uplift) { 98.16 }
  let(:calls_after_uplift) { 23.52 }
  let(:total_cost) { 121.68 }

  before do
    allow(Steps::LettersCallsForm).to receive(:build).and_return(letters_calls_form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::LettersCallsForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Letters and phone calls')
    end
  end

  describe '#row_data' do
    context 'letters and calls have uplift' do
      it 'generates hearing details rows' do
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
            }
          ]
        )
      end
    end

    context 'letters and calls have no uplift' do
      let(:letters_uplift) { nil }
      let(:calls_uplift) { nil }
      let(:letters_after_uplift) { 81.80 }
      let(:calls_after_uplift) { 20.45 }
      let(:total_cost) { 102.25 }

      it 'generates hearing details rows' do
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
              text: '0%'
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
              head_key: 'calls_uplift',
              text: '0%'
            },
            {
              head_key: 'calls_payment',
              text: '£20.45'
            },
            {
              head_key: 'total',
              text: '<strong>£102.25</strong>',
              footer: true
            }
          ]
        )
      end
    end
  end
end
