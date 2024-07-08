require 'rails_helper'

RSpec.describe TestData::NsmBuilder do
  describe '#build_many' do
    let(:client) { double(AppStoreClient, post: true) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
    end

    it 'can create multiple bulk claims' do
      expect { subject.build_many(bulk: 2, large: 0, sleep: false) }.to change(Claim, :count).by(2)
    end

    it 'can create multiple large claims' do
      expect { subject.build_many(bulk: 0, large: 2, sleep: false) }.to change(Claim, :count).by(2)
    end

    it 'can create multiple bulk and large claims' do
      expect { subject.build_many(bulk: 2, large: 2, sleep: false) }.to change(Claim, :count).by(4)
    end

    it 'can create claims for a specific year' do
      subject.build_many(bulk: 1, large: 1, year: 2020, sleep: false)
      data = Claim.pluck(:ufn, :rep_order_date, :cntp_date)

      expect(data.count).to eq(2)

      data.each do |ufn, rep_order_date, cntp_date|
        expect(ufn).to match(%r{\A\d{6}/\d{3}\z})
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

    context 'instructed to sleep' do
      it 'runs with delay' do
        expect(subject).to receive(:sleep).twice

        subject.build_many(bulk: 1, large: 1, sleep: true)
      end
    end

    context 'when claim is invalid (not completed)' do
      let(:incomplete_form) { instance_double(Nsm::Tasks::CaseDetails, completed?: false) }

      before do
        allow(Nsm::Tasks::CaseDetails).to receive(:new).and_return(incomplete_form)
      end

      it 'runs raises and error' do
        expect { subject.build_many }.to raise_error('Invalid for CaseDetails')
      end
    end
  end

  describe '#options' do
    subject(:options) { described_class.new.options[key] }

    context 'magistrates' do
      let(:key) { :magistrates }

      it 'has the arguements' do
        expect(options[0]).to eq([:claim, :complete, :case_type_magistrates, :build_associates])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          disbursements_count: (0..25),
          work_items_count: (1..50),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31))
        )
      end
    end

    context 'breach' do
      let(:key) { :breach }

      it 'has the arguements' do
        expect(options[0]).to eq([:claim, :complete, :case_type_breach, :build_associates])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          disbursements_count: (0..25),
          work_items_count: (1..50),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31))
        )
      end
    end

    context 'no_disbursements' do
      let(:key) { :no_disbursements }

      it 'has the arguements' do
        expect(options[0]).to eq([:claim, :complete, :case_type_magistrates, :build_associates])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          disbursements_count: 0,
          work_items_count: (1..50),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31))
        )
      end
    end

    context 'enhanced_rates' do
      let(:key) { :enhanced_rates }

      it 'has the arguements' do
        expect(options[0]).to eq([:claim, :complete, :case_type_magistrates, :with_enhanced_rates, :build_associates])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          disbursements_count: (0..25),
          work_items_count: (1..50),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31))
        )
      end
    end
  end
end
