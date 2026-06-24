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
    let(:client) { instance_double(AppStoreClient) }
    let(:caseworker_client) { instance_double(TestData::AppStoreCaseworkerClient) }
    let(:stored_payloads) { {} }

    before do
      allow(client).to receive(:post) do |payload|
        stored_payloads[payload[:application_id]] = payload.deep_stringify_keys
        true
      end
      allow(client).to receive(:put) do |payload, **_kwargs|
        stored_payloads[payload[:application_id]] = payload.deep_stringify_keys
        true
      end
      allow(caseworker_client).to receive(:put) do |payload|
        stored_payloads[payload[:application_id]] = payload.deep_stringify_keys
        true
      end
      allow(client).to receive(:get) do |application_id|
        stored_payloads.fetch(application_id).deep_dup
      end
      allow(AppStoreClient).to receive(:new).and_return(client)
      allow(TestData::AppStoreCaseworkerClient).to receive(:new).and_return(caseworker_client)
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

    it 'uses the primary dev provider for the default local data shape' do
      allow(HostEnv).to receive_messages(local?: true, development?: false)

      subject.build_many(bulk: 1, large: 0, sleep: false)

      expect(Claim.last).to have_attributes(
        submitter: have_attributes(email: 'provider@example.com'),
        office_code: be_in(%w[1A123B 2A555X])
      )
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
      result = subject.build_many(bulk: 3, large: 0, version_mix: { 1 => 1, 2 => 1, 3 => 1 }, sleep: false)

      expect(result[:versions]).to eq 6
      expect(client).to have_received(:post).exactly(3).times
      expect(caseworker_client).to have_received(:put)
        .with(hash_including(application_state: 'sent_back'))
        .twice
      expect(client).to have_received(:put).with(hash_including(application_state: 'provider_updated')).once
    end

    it 'creates valid sent-back transitions before provider-updated versions' do
      subject.build_many(bulk: 1, large: 0, version_mix: { 3 => 1 }, sleep: false)

      claim = Claim.last
      expect(claim).to be_provider_updated
      expect(claim.further_informations.last.information_supplied).to be_present
      expect(client).to have_received(:post).with(hash_including(application_state: 'submitted')).ordered
      expect(caseworker_client).to have_received(:put)
        .with(hash_including(application_state: 'sent_back'))
        .ordered
      expect(client).to have_received(:put).with(hash_including(application_state: 'provider_updated')).ordered
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

  describe '#version_payload_for' do
    let(:claim) { create(:claim) }
    let(:latest_payload) do
      {
        application: {
          status: 'submitted',
        },
      }
    end

    before do
      allow(LaaCrimeFormsCommon::Validator).to receive(:validate).and_return([])
    end

    it 'includes a nil resubmission deadline when none exists' do
      payload = subject.send(:version_payload_for, claim, latest_payload, 'sent_back')

      expect(payload[:application]).to include(
        'further_information' => [],
        'resubmission_deadline' => nil,
        'status' => 'sent_back'
      )
    end
  end

  describe '#validate_version_payload!' do
    it 'raises validation issues' do
      claim = build_stubbed(:claim)
      application = { 'status' => 'sent_back' }

      allow(LaaCrimeFormsCommon::Validator).to receive(:validate)
        .with(:nsm, application)
        .and_return(['invalid status'])

      expect { subject.send(:validate_version_payload!, claim, application) }.to raise_error(
        "Validation issues detected for #{claim.id}: invalid status"
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
