require 'rails_helper'

RSpec.describe ReasonForClaim do
  subject { described_class.new(value, date_field:, text_field:) }

  let(:value) { :foo }
  let(:date_field) { nil }
  let(:text_field) { nil }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          core_costs_exceed_higher_limit
          enhanced_rates_claimed
          councel_or_agent_assigned
          representation_order_withdrawn
          extradition
          other
        ]
      )
    end
  end

  describe '#initialization' do
    it 'date and text fields are optional' do
      expect { described_class.new(value) }.not_to raise_error
    end
  end

  describe '#date_field?' do
    context 'when date field is set' do
      let(:date_field) { :date }

      it { expect(subject).to be_date_field }
    end

    context 'when text field is not set' do
      it { expect(subject).not_to be_date_field }
    end
  end

  describe '#text_field?' do
    context 'when text field is set' do
      let(:text_field) { :text }

      it { expect(subject).to be_text_field }
    end

    context 'when text field is not set' do
      it { expect(subject).not_to be_text_field }
    end
  end
end
