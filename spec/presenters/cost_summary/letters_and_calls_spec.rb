require 'rails_helper'

RSpec.describe CostSummary::LettersCalls do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) { instance_double(Steps::LettersCallsForm, letters_total:, calls_total:, total_cost:) }
  let(:letters_total) { 25.0 }
  let(:calls_total) { 75.0 }
  let(:total_cost) { 100.00 }

  before do
    allow(Steps::LettersCallsForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::LettersCallsForm).to have_received(:build).with(claim)
    end
  end

  describe '#rows' do
    it 'generates letters and calls rows' do
      expect(subject.rows).to eq(
        [
          {
            key: { classes: 'govuk-summary-list__value-width-50', text: 'Letters' },
            value: { text: '£25.00' }
          },
          {
            key: { classes: 'govuk-summary-list__value-width-50', text: 'Phone calls' },
            value: { text: '£75.00' }
          },
        ]
      )
    end
  end

  describe '#total_cost' do
    it 'delegates to the form' do
      expect(subject.total_cost).to eq(100.00)
    end
  end

  describe '#title' do
    it 'translates with total cost' do
      expect(subject.title).to eq('Letters and phone calls total £100.00')
    end
  end
end
