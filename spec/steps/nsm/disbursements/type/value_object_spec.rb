require 'rails_helper'

RSpec.describe DisbursementTypes do
  subject { described_class.new(value) }

  let(:value) { :car }

  describe '.values' do
    it 'returns all possible values' do
      expect(described_class.values.map(&:to_s)).to eq(
        %w[
          car
          motorcycle
          bike
          other
        ]
      )
    end
  end

  describe '#hint' do
    let(:pricing) { instance_double(Pricing, '[]': price) }
    let(:price) { 0.45 }
    let(:application) { instance_double(Claim) }

    before do
      allow(Pricing).to receive(:for).and_return(pricing)
    end

    it 'get the pricing based on the application' do
      subject.hint(application)
      expect(Pricing).to have_received(:for).with(application)
    end

    context 'when rate exists' do
      let(:price) { 0.4 }

      it { expect(subject.hint(application)).to eq('£0.40 per mile') }
    end

    context 'when rate does not exist' do
      let(:price) { nil }

      it { expect(subject.hint(application)).to be_nil }
    end
  end
end
