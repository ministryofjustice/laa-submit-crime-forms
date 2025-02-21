require 'rails_helper'

RSpec.describe Nsm::Importers::Xml::V1::Importer do
  subject { described_class.new(claim, hash) }

  let(:import_form) { Nsm::ImportForm.new }
  let(:file_upload) { double(:file_upload, tempfile: File.new('spec/fixtures/files/import_sample.xml')) }

  let(:claim) { create(:claim) }
  let(:xml_hash) { Nsm::Importers::Xml::ImportService.new(claim, import_form).xml_hash }
  let(:hash) { xml_hash }

  before do
    allow(import_form).to receive(:file_upload).and_return(file_upload)
    subject.call
  end

  describe '#call' do
    # rubocop:disable RSpec::ExampleLength
    it 'updates claim model attributes with hash values' do
      expect(claim.ufn).to eq(hash['ufn'])
      expect(claim.office_code).to eq(hash['office_code'])
      expect(claim.claim_type).to eq(hash['claim_type'])
      expect(claim.rep_order_date).to eq(Date.parse(hash['rep_order_date']))
      expect(claim.reasons_for_claim).to eq(hash['reasons_for_claim'])
      expect(claim.representation_order_withdrawn_date).to eq(Date.parse(hash['representation_order_withdrawn_date']))
      expect(claim.reason_for_claim_other_details).to eq(hash['reason_for_claim_other_details'])
      expect(claim.main_offence).to eq(hash['main_offence'])
      expect(claim.main_offence_date).to eq(Date.parse(hash['main_offence_date']))
      expect(claim.assigned_counsel).to eq(hash['assigned_counsel'])
      expect(claim.unassigned_counsel).to eq(hash['unassigned_counsel'])
      expect(claim.agent_instructed).to eq(hash['agent_instructed'])
      expect(claim.remitted_to_magistrate).to eq(hash['remitted_to_magistrate'])
      expect(claim.plea).to eq(hash['plea'])
      expect(claim.arrest_warrant_date).to eq(Date.parse(hash['arrest_warrant_date']))
      expect(claim.first_hearing_date).to eq(Date.parse(hash['first_hearing_date']))
      expect(claim.number_of_hearing).to eq(hash['number_of_hearing'].to_i)
      expect(claim.court).to eq(hash['court'])
      expect(claim.youth_court).to eq(hash['youth_court'])
      expect(claim.hearing_outcome).to eq(hash['hearing_outcome'])
      expect(claim.matter_type).to eq(hash['matter_type'])
      expect(claim.prosecution_evidence).to eq(hash['prosecution_evidence'].to_i)
      expect(claim.defence_statement).to eq(hash['defence_statement'].to_i)
      expect(claim.number_of_witnesses).to eq(hash['number_of_witnesses'].to_i)
      expect(claim.supplemental_claim).to eq(hash['supplemental_claim'])
      expect(claim.time_spent).to eq(hash['time_spent'].to_i)
      expect(claim.letters).to eq(hash['letters'].to_i)
      expect(claim.calls).to eq(hash['calls'].to_i)
      expect(claim.other_info).to eq(hash['other_info'])
      expect(claim.conclusion).to eq(hash['conclusion'])
      expect(claim.concluded).to eq(hash['concluded'])
      expect(claim.letters_uplift).to eq(hash['letters_uplift'].to_i)
      expect(claim.work_before_date).to eq(Date.parse(hash['work_before_date']))
      expect(claim.work_after_date).to eq(Date.parse(hash['work_after_date']))
      expect(claim.gender).to eq(hash['gender'])
      expect(claim.remitted_to_magistrate_date).to eq(Date.parse(hash['remitted_to_magistrate_date']))
      expect(claim.preparation_time).to eq(hash['preparation_time'])
      expect(claim.work_before).to eq(hash['work_before'])
      expect(claim.work_after).to eq(hash['work_after'])
      expect(claim.has_disbursements).to eq(hash['has_disbursements'])
      expect(claim.is_other_info).to eq(hash['is_other_info'])
      expect(claim.plea_category).to eq(hash['plea_category'])
      expect(claim.wasted_costs).to eq(hash['wasted_costs'])
      expect(claim.work_completed_date).to eq(Date.parse(hash['work_completed_date']))
      expect(claim.office_in_undesignated_area).to eq(ActiveModel::Type::Boolean.new.cast(hash['office_in_undesignated_area']))
      expect(claim.court_in_undesignated_area).to eq(ActiveModel::Type::Boolean.new.cast(hash['court_in_undesignated_area']))
      expect(claim.main_offence_type).to eq(hash['main_offence_type'])
    end
    # rubocop:enable RSpec::ExampleLength
  end

  describe '#create_work_items' do
    it 'creates work items' do
      expect(claim.work_items.find_by(position: 1)).to have_attributes(
        work_type: 'preparation',
        time_spent: 120,
        completed_on: Date.new(2024, 1, 15),
        fee_earner: 'JS',
        uplift: 20,
        position: 1,
      )
    end

    describe 'no item' do
      let(:hash) { xml_hash.except!('work_items') }

      it 'returns nil if no work items are present' do
        expect(claim.work_items.count).to be_zero
      end
    end
  end

  describe '#create_disbursements' do
    it 'creates disbursements' do
      expect(claim.disbursements.find_by(miles: nil)).to have_attributes(
        disbursement_type: 'other',
        other_type: 'psychiatric_reports',
        total_cost_without_vat: 350.00,
        details: 'Expert psychiatric assessment',
        apply_vat: 'true',
        vat_amount: 70.00,
      )
      expect(claim.disbursements.find_by(disbursement_type: 'car')).to have_attributes(
        miles: 45.5,
        details: 'Travel to Liverpool Magistrates Court',
        apply_vat: 'true',
        vat_amount: 4.09,
      )
    end

    describe 'no disbursements' do
      let(:hash) { xml_hash.except!('disbursements', 'disbursement') }

      it 'does not create disbursements' do
        expect(claim.disbursements.count).to be_zero
      end
    end
  end

  describe '#create_defendants' do
    it 'creates defendants' do
      expect(claim.defendants.count).to be(2)
    end

    describe 'no defendants' do
      let(:hash) { xml_hash.except!('defendants') }

      it 'returns nil if no defendants are present' do
        expect(claim.defendants.count).to be_zero
      end
    end
  end

  describe '#create_firm_office' do
    it 'creates office if present' do
      expect(claim.firm_office).to have_attributes(address_line_1: '123 Law Street',
                                                   address_line_2: 'Suite 100',
                                                   name: 'Legal Eagles LLP',
                                                   postcode: 'FK9 4LA',
                                                   town: 'Liverpool',
                                                   vat_registered: 'yes')
    end

    describe 'returns nil if no firm present' do
      let(:hash) { xml_hash.except!('firm_office') }

      it 'returns nil if no firm present' do
        expect(claim.firm_office).to be_nil
      end
    end
  end

  describe '#enhanced_rates_if_uplifts' do
    context 'when no uplifts present' do
      let(:hash) do
        xml_hash.except!('calls_uplift', 'letters_uplift')
        xml_hash.tap { |h| h['work_items']['work_item'].each { _1.delete('uplift') } }
      end

      it 'enhanced_rates_claimed not included if uplifts absent' do
        expect(claim.reasons_for_claim).not_to include('enhanced_rates_claimed')
      end
    end

    it 'adds enhanced_rates_claimed if uplifts present' do
      expect(claim.reasons_for_claim).to include('enhanced_rates_claimed')
    end
  end

  describe '#create_solicitor' do
    it 'creates solicitor if present' do
      expect(claim.solicitor).to have_attributes(first_name: 'Mickey',
                                                 last_name: 'Dolenz',
                                                 reference_number: '1234456',
                                                 contact_first_name: 'Davy',
                                                 contact_last_name: 'Jones',
                                                 contact_email: 'davy@jones.com')
    end

    describe 'returns nil if no solicitor present' do
      let(:hash) { xml_hash.except!('solicitor') }

      it 'returns nil if no solicitor present' do
        expect(claim.solicitor).to be_nil
      end
    end
  end
end
