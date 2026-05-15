require 'rails_helper'

RSpec.describe TestData::NsmBuilder do
  describe '.parse_claim_type_mix' do
    it 'returns nil for blank values' do
      expect(described_class.parse_claim_type_mix(nil)).to be_nil
    end

    it 'parses comma-separated claim type weights' do
      expect(described_class.parse_claim_type_mix('nsm:80,boi:5,supplemental:15')).to eq(
        nsm: 80,
        boi: 5,
        supplemental: 15
      )
    end

    it 'rejects unsupported claim types' do
      expect { described_class.parse_claim_type_mix('nsm:80,bio:20') }.to raise_error(
        ArgumentError,
        'CLAIM_TYPE_MIX supports nsm, boi, breach, supplemental, enhanced_rates with positive integer weights'
      )
    end

    it 'rejects non-positive weights' do
      expect { described_class.parse_claim_type_mix('nsm:80,boi:0') }.to raise_error(
        ArgumentError,
        'CLAIM_TYPE_MIX supports nsm, boi, breach, supplemental, enhanced_rates with positive integer weights'
      )
    end

    it 'rejects malformed claim type weights' do
      expect { described_class.parse_claim_type_mix('nsm:80,boi') }.to raise_error(
        ArgumentError,
        'CLAIM_TYPE_MIX supports nsm, boi, breach, supplemental, enhanced_rates with positive integer weights'
      )
    end
  end

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

    it 'creates claims across generated providers and office codes' do
      subject.build_many(bulk: 4, large: 0, providers: 2, office_codes: 4, high_volume_claim_ratio: 0, sleep: false)

      expect(Provider.where("email LIKE 'test-data-provider-%@example.com'").count).to eq 2
      expect(Claim.distinct.pluck(:office_code).count).to be > 1
      expect(Claim.includes(:submitter)).to all(satisfy { |claim| claim.submitter.office_codes.include?(claim.office_code) })
    end

    it 'returns summary statistics for the generated data' do
      result = subject.build_many(bulk: 2, large: 1, providers: 2, office_codes: 3, sleep: false)

      expect(result).to include(
        providers: 2,
        office_codes: 3,
        claims: 3,
        versions: 3,
      )
      expect(result[:claims_per_office_code].values.sum).to eq 3
    end

    it 'submits additional app store versions when configured' do
      app_store_claim = instance_spy(AppStore::V1::Nsm::Claim)
      submitter = instance_spy(SubmitToAppStore, submit: true)
      allow(SubmitToAppStore).to receive(:new).and_return(submitter)
      allow(subject).to receive(:app_store_claim_for).and_return(app_store_claim)

      result = subject.build_many(bulk: 3, large: 0, version_mix: { 1 => 1, 2 => 1, 3 => 1 }, sleep: false)

      expect(result[:versions]).to eq 6
      expect(submitter).to have_received(:submit).exactly(6).times
      expect(app_store_claim).to have_received(:provider_updated!).exactly(3).times
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
      let(:incomplete_form) { instance_double(Nsm::Tasks::CaseDetails, completed?: false, not_applicable?: false) }

      before do
        allow(Nsm::Tasks::CaseDetails).to receive(:new).and_return(incomplete_form)
      end

      it 'runs raises and error' do
        expect { subject.build_many }.to raise_error('Invalid for CaseDetails')
      end
    end
  end

  describe '#build' do
    context 'when submit is passed in as false' do
      it 'does not submit the claim' do
        id = subject.build(submit: false, min: 2, max: 2)

        expect(Claim.find(id)).to have_attributes(
          state: 'draft'
        )
      end
    end

    it 'can build a vanilla non-supplemental NSM claim' do
      id = subject.build(submit: false, claim_type_mix: { nsm: 1 })

      expect(Claim.find(id)).to have_attributes(
        claim_type: ClaimType::NON_STANDARD_MAGISTRATE.to_s,
        supplemental_claim: 'no'
      )
    end

    it 'can build a breach of injunction claim' do
      id = subject.build(submit: false, claim_type_mix: { boi: 1 })

      expect(Claim.find(id)).to have_attributes(
        claim_type: ClaimType::BREACH_OF_INJUNCTION.to_s,
      )
    end

    it 'can build a supplemental NSM claim' do
      id = subject.build(submit: false, claim_type_mix: { supplemental: 1 })

      expect(Claim.find(id)).to have_attributes(
        claim_type: ClaimType::NON_STANDARD_MAGISTRATE.to_s,
        supplemental_claim: 'yes'
      )
    end
  end

  describe '#app_store_claim_for' do
    it 'builds an app store claim from the current app store payload' do
      claim = build_stubbed(:claim)
      payload = {
        'application_id' => claim.id,
        'application_state' => 'submitted',
        'application' => {
          'office_code' => 'T00001'
        }
      }

      allow(AppStoreClient).to receive(:new).and_return(instance_double(AppStoreClient, get: payload))

      expect(subject.send(:app_store_claim_for, claim)).to have_attributes(
        id: claim.id,
        office_code: 'T00001'
      )
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

      context 'when year is set to the current year' do
        subject(:options) { described_class.new.options(year: 2024)[key] }

        before { travel_to Date.new(2024, 8, 1) }

        it 'uses appropriate date ranges' do
          expect(options[1].call).to match(
            date: (Date.new(2024, 1, 1)...Date.current),
            updated_at: (Date.new(2024, 1, 1)...Date.current),
            disbursements_count: (0..25),
            work_items_count: (1..50),
          )
        end
      end
    end

    context 'vanilla_nsm' do
      let(:key) { :vanilla_nsm }

      it 'has the arguements' do
        expect(options[0]).to eq([:claim, :complete, :case_type_magistrates, :claim_details_no, :build_associates])
      end
    end

    context 'supplemental' do
      let(:key) { :supplemental }

      it 'has the arguements' do
        expect(options[0]).to eq([:claim, :complete, :case_type_magistrates, :build_associates])
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
