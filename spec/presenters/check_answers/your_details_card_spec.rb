require 'rails_helper'

RSpec.describe CheckAnswers::YourDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) do
    instance_double(Steps::FirmDetailsForm, firm_office:, solicitor:)
  end
  let(:firm_office) do
    instance_double(Steps::FirmDetails::FirmOfficeForm, name: firm_name,
    account_number: firm_account_number, address_line_1: firm_address_1, address_line_2: firm_address_2,
    town: firm_town, postcode: firm_postcode)
  end
  let(:solicitor) do
    instance_double(Steps::FirmDetails::SolicitorForm, full_name: solicitor_full_name,
    reference_number: solicitor_ref_number, contact_full_name: contact_full_name)
  end
  let(:firm_name) { 'Firm A' }
  let(:firm_account_number) { '123ABC' }
  # rubocop:disable RSpec/IndexedLet
  let(:firm_address_1) { '2 Laywer Suite' }
  let(:firm_address_2) { 'Unit B' }
  # rubocop:enable RSpec/IndexedLet
  let(:firm_town) { 'Lawyer Town' }
  let(:firm_postcode) { 'CR0 1RE' }
  let(:solicitor_full_name) { 'Richard Jenkins' }
  let(:solicitor_ref_number) { '111222' }
  let(:contact_full_name) { 'James Blake' }

  before do
    allow(Steps::FirmDetailsForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::FirmDetailsForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Your Details')
    end
  end

  describe '#route_path' do
    it 'is correct route' do
      expect(subject.route_path).to eq('firm_details')
    end
  end

  describe '#row_data' do
    context '2 lines in address' do
      it 'generates case detail rows with 2 lines of address' do
        expect(subject.row_data[:firm_name][:text]).to eq('Firm A')
        expect(subject.row_data[:firm_account_number][:text]).to eq('123ABC')
        expect(subject.row_data[:firm_address][:text]).to eq('2 Laywer Suite<br>Unit B<br>Lawyer Town<br>CR0 1RE')
        expect(subject.row_data[:solicitor_full_name][:text]).to eq('Richard Jenkins')
        expect(subject.row_data[:solicitor_reference_number][:text]).to eq('111222')
        expect(subject.row_data[:contact_full_name][:text]).to eq('James Blake')
      end
    end

    context '1 line in address' do
      let(:firm_address_2) { nil }

      it 'generates case detail rows with 1 line of address' do
        expect(subject.row_data[:firm_name][:text]).to eq('Firm A')
        expect(subject.row_data[:firm_account_number][:text]).to eq('123ABC')
        expect(subject.row_data[:firm_address][:text]).to eq('2 Laywer Suite<br>Lawyer Town<br>CR0 1RE')
        expect(subject.row_data[:solicitor_full_name][:text]).to eq('Richard Jenkins')
        expect(subject.row_data[:solicitor_reference_number][:text]).to eq('111222')
        expect(subject.row_data[:contact_full_name][:text]).to eq('James Blake')
      end
    end
  end
end
