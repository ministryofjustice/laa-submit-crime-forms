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

    it 'creates applications across generated providers and office codes' do
      subject.build_many(bulk: 4, providers: 2, office_codes: 4, high_volume_claim_ratio: 0, sleep: false)

      expect(Provider.where("email LIKE 'test-data-provider-%@example.com'").count).to eq 2
      expect(PriorAuthorityApplication.distinct.pluck(:office_code).count).to be > 1
      expect(PriorAuthorityApplication.includes(:provider)).to all(
        satisfy { |application| application.provider.office_codes.include?(application.office_code) }
      )
    end

    it 'returns summary statistics for the generated data' do
      result = subject.build_many(bulk: 3, providers: 2, office_codes: 3, sleep: false)

      expect(result).to include(
        providers: 2,
        office_codes: 3,
        applications: 3,
        versions: 3,
      )
      expect(result[:applications_per_office_code].values.sum).to eq 3
    end

    it 'submits additional app store versions when configured' do
      submitter = instance_spy(SubmitToAppStore, submit: true)
      allow(SubmitToAppStore).to receive(:new).and_return(submitter)

      result = subject.build_many(bulk: 3, version_mix: { 1 => 1, 2 => 1, 3 => 1 }, sleep: false)

      expect(result[:versions]).to eq 6
      expect(submitter).to have_received(:submit).exactly(6).times
    end

    it 'can applications claims for a specific year' do
      subject.build_many(bulk: 2, year: 2020, sleep: false)
      data = PriorAuthorityApplication.order(:created_at).last(2).pluck(:ufn)

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

  describe '#log' do
    it 'prints outside the test environment' do
      allow(Rails.env).to receive(:test?).and_return(false)
      expect(subject).to receive(:print).with('message')

      subject.send(:log, 'message')
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

      context 'when year is set to the current year' do
        subject(:options) { described_class.new.options(year: 2024)[key] }

        before { travel_to Date.new(2024, 8, 1) }

        it 'uses appropriate date ranges' do
          expect(options[1].call).to match(
            date: (Date.new(2024, 1, 1)...Date.current),
            updated_at: (Date.new(2024, 1, 1)...Date.current),
            service_type_cost_type: be_one_of(:per_item, :per_hour),
          )
        end
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
