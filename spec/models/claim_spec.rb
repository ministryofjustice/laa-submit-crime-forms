require 'rails_helper'

RSpec.describe Claim do
  subject { described_class.new(attributes) }

  describe '#date' do
    context 'when rep_order_date is set' do
      let(:attributes) { { rep_order_date: } }
      let(:rep_order_date) { Date.yesterday }

      it 'returns the rep_order_date' do
        expect(subject.date).to eq(rep_order_date)
      end
    end

    context 'when cntp_date is set' do
      let(:attributes) { { cntp_date: } }
      let(:cntp_date) { Date.yesterday }

      it 'returns the cntp_date' do
        expect(subject.date).to eq(cntp_date)
      end
    end

    context 'when neither rep_order_date or cntp_date is set' do
      let(:attributes) { {} }

      it 'returns nil' do
        expect(subject.date).to be_nil
      end
    end
  end

  context 'short_id' do
    let(:attributes) { { id: SecureRandom.uuid } }

    it 'returns the first 8 characters of the id' do
      expect(subject.short_id).to eq(subject.id.first(8))
    end
  end
end
