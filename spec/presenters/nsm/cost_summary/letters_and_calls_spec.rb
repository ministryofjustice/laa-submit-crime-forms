require 'rails_helper'

RSpec.describe Nsm::CostSummary::LettersCalls do
  subject { described_class.new(claim) }

  let(:claim) do
    instance_double(Claim, firm_office:, letters_after_uplift:, calls_after_uplift:, letters_and_calls_total_cost:,
letters_and_calls_total_cost_inc_vat:)
  end
  let(:firm_office) { build(:firm_office, :valid) }
  let(:letters_after_uplift) { 25.0 }
  let(:calls_after_uplift) { 75.0 }
  let(:letters_and_calls_total_cost) { 100.00 }
  let(:letters_and_calls_total_cost_inc_vat) { 120.00 }

  describe '#rows' do
    it 'generates letters and calls rows' do
      expect(subject.rows).to eq(
        [[{ classes: 'govuk-table__header', text: 'Letters' },
          { classes: 'govuk-table__cell--numeric', text: '£25.00' }],
         [{ classes: 'govuk-table__header', text: 'Phone calls' },
          { classes: 'govuk-table__cell--numeric', text: '£75.00' }]]
      )
    end
  end

  context 'vat registered' do
    describe '#total_cost' do
      it 'delegates to the form' do
        expect(subject.total_cost).to eq(100.00)
      end
    end

    describe '#title' do
      it 'translates without total cost' do
        expect(subject.title).to eq('Letters and phone calls')
      end
    end
  end

  context 'not vat registered' do
    let(:firm_office) { build(:firm_office, :full) }
    let(:letters_and_calls_total_cost_inc_vat) { 0.00 }

    describe '#total_cost' do
      it 'delegates to the form' do
        expect(subject.total_cost).to eq(100.00)
      end
    end

    describe '#title' do
      it 'translates without total cost' do
        expect(subject.title).to eq('Letters and phone calls')
      end
    end
  end
end
