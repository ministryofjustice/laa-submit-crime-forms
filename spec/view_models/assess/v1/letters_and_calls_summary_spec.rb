require 'rails_helper'

RSpec.describe Assess::V1::LettersAndCallsSummary, type: :model do
  subject { described_class.new(claim:) }

  before do
    allow(CostCalculator).to receive(:cost).and_return(10.50)
  end

  let(:letters_and_calls) do
    [{ 'type' => { 'en' => 'Letters', 'value' => 'letters' }, 'count' => 12, 'uplift' => uplift, 'pricing' => 3.56 }]
  end
  let(:uplift) { 0 }
  let(:claim) { build(:submitted_claim).tap { |claim| claim.data.merge!('letters_and_calls' => letters_and_calls) } }

  describe '#summary_row' do
    it 'returns an array of summary row fields' do
      expect(subject.summary_row).to eq(['12', '-', '£10.50', '-', '£10.50'])
    end
  end

  describe 'uplift?' do
    context 'when uplift is 0' do
      it { expect(subject).not_to be_uplift }
    end

    context 'when uplift is positive' do
      let(:uplift) { 100 }

      it { expect(subject).to be_uplift }
    end

    context 'when uplift is nil' do
      let(:uplift) { nil }

      it { expect(subject).not_to be_uplift }
    end
  end
end
