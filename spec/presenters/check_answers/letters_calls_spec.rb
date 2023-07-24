require 'rails_helper'

RSpec.describe CheckAnswers::LettersCallsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:letters_calls_form) do
    instance_double(Steps::LettersCallsForm, letters:, calls:)
  end

  let(:letters) { 20 }
  let(:calls) { 5 }

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
    it 'generates hearing details rows' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: 'letters',
            text: 20
          },
          {
            head_key: 'calls',
            text: 5
          }
        ]
      )
    end
  end
end
