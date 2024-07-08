require 'rails_helper'

RSpec.describe TestData::PaBuilder do
  describe '#build_many' do
    let(:client) { double(AppStoreClient, post: true) }

    before do
      allow(AppStoreClient).to receive(:new).and_return(client)
    end

    it 'can create multiple applications' do
      expect { subject.build_many(bulk: 2, sleep: false) }.to change(PriorAuthorityApplication, :count).by(2)
    end

    it 'can applications claims for a specific year' do
      subject.build_many(bulk: 2, year: 2020, sleep: false)
      data = PriorAuthorityApplication.pluck(:ufn)

      expect(data.count).to eq(2)

      data.all? do |ufn|
        expect(ufn).to match(%r{\A\d{6}/\d{3}\z})
      end
    end

    context 'when hostenv is production' do
      before do
        allow(HostEnv).to receive(:production?).and_return(true)
      end

      it 'runs does not run' do
        expect { subject.build_many(bulk: 1) }.to raise_error('Do not run on production')
      end
    end

    context 'when instructed to sleep' do
      it 'runs with delay' do
        expect(subject).to receive(:sleep).twice

        subject.build_many(bulk: 2, sleep: true)
      end
    end

    context 'when claim is invalid (not completed)' do
      let(:incomplete_form) { instance_double(PriorAuthority::Tasks::CaseContact, completed?: false) }

      before do
        allow(PriorAuthority::Tasks::CaseContact).to receive(:new).and_return(incomplete_form)
      end

      it 'runs raises and error' do
        expect { subject.build_many }.to raise_error('Invalid for CaseContact')
      end
    end
  end

  describe '#options' do
    subject(:options) { described_class.new.options[key] }

    context 'simple_non_prision' do
      let(:key) { :simple_non_prision }

      it 'has the arguements' do
        expect(options[0]).to eq([:prior_authority_application, :with_complete_non_prison_law])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          service_type_cost_type: be_one_of(:per_item, :per_hour)
        )
      end
    end

    context 'simple_prision' do
      let(:key) { :simple_prision }

      it 'has the arguements' do
        expect(options[0]).to eq([:prior_authority_application, :with_complete_prison_law])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          service_type_cost_type: be_one_of(:per_item, :per_hour)
        )
      end
    end

    context 'complex_non_prision' do
      let(:key) { :complex_non_prision }

      it 'has the arguements' do
        expect(options[0]).to eq([:prior_authority_application, :with_complete_non_prison_law, :with_alternative_quotes,
                                  :with_additional_costs])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          service_type_cost_type: be_one_of(:per_item, :per_hour),
          quote_count: (1..2)
        )
      end
    end

    context 'complex_prision' do
      let(:key) { :complex_prision }

      it 'has the arguements' do
        expect(options[0]).to eq([:prior_authority_application, :with_complete_prison_law, :with_alternative_quotes,
                                  :with_additional_costs])
      end

      it 'has the kwargs' do
        expect(options[1].call).to match(
          date: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          updated_at: (Date.new(2023, 1, 1)..Date.new(2023, 12, 31)),
          service_type_cost_type: be_one_of(:per_item, :per_hour),
          quote_count: (1..2)
        )
      end
    end
  end
end
