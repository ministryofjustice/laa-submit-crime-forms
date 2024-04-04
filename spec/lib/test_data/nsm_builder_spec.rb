require 'rails_helper'

RSpec.describe TestData::NsmBuilder do
  describe '#build_many' do
    let(:client) { double(AppStoreClient, post: true) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
    end

    it 'can create multiple bulk claims' do
      expect { subject.build_many(bulk: 2, large: 0) }.to change(Claim, :count).by(2)
    end

    it 'can create multiple large claims' do
      expect { subject.build_many(bulk: 0, large: 2) }.to change(Claim, :count).by(2)
    end

    it 'can create multiple bulk and large claims' do
      expect { subject.build_many(bulk: 2, large: 2) }.to change(Claim, :count).by(4)
    end

    it 'can create claims for a specific year' do
      subject.build_many(bulk: 1, large: 1, year: 2020)
      data = Claim.pluck(:ufn, :rep_order_date, :cntp_date)

      expect(data.count).to eq(2)

      data.each do |ufn, rep_order_date, cntp_date|
        expect(ufn).to match(%r{\A\d{4}20/00\d\z})
        date = rep_order_date || cntp_date
        expect(date.year).to eq(2020)
      end
    end

    context 'when hostenv is production' do
      before do
        allow(HostEnv).to receive(:production?).and_return(true)
      end

      it 'runs does not run' do
        expect { subject.build_many(bulk: 1, large: 0) }.to raise_error('Do not run on production')
      end
    end

    context 'when hostenv is not local' do
      before do
        allow(HostEnv).to receive_messages(production?: false, local?: false)
      end

      it 'runs with delay' do
        expect(subject).to receive(:sleep)

        subject.build_many(bulk: 1, large: 0)
      end
    end
  end
end
