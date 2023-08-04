require 'rails_helper'

RSpec.describe CheckAnswers::YourDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :full_firm_details) }

  describe '#initialize' do
    it 'creates the data instance' do
      expect(Steps::FirmDetailsForm).to receive(:build).with(claim)
      subject
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Your details')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#row_data' do
    context '2 lines in address' do
      it 'generates case detail rows with 2 lines of address' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'firm_name',
              text: 'Firm A'
            },
            {
              head_key: 'firm_account_number',
              text: '123ABC'
            },
            {
              head_key: 'firm_address',
              text: '2 Laywer Suite<br>Unit B<br>Lawyer Town<br>CR0 1RE'
            },
            {
              head_key: 'solicitor_full_name',
              text: 'Richard Jenkins'
            },
            {
              head_key: 'solicitor_reference_number',
              text: '111222'
            },
            {
              head_key: 'contact_full_name',
              text: 'James Blake'
            },
            {
              head_key: "contact_email",
              text: "james@email.com"
            }
          ]
        )
      end
    end

    context 'without optional infomation' do
      let(:claim) { build(:claim, :firm_details) }

      it 'generates case detail rows for required fields' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'firm_name',
              text: 'Firm A'
            },
            {
              head_key: 'firm_account_number',
              text: '123ABC'
            },
            {
              head_key: 'firm_address',
              text: '2 Laywer Suite<br>Lawyer Town<br>CR0 1RE'
            },
            {
              head_key: 'solicitor_full_name',
              text: 'Richard Jenkins'
            },
            {
              head_key: 'solicitor_reference_number',
              text: '111222'
            },
          ]
        )
      end
    end

    context 'with no data' do
      let(:claim) { build(:claim) }

      it 'generates missing data rows for required fields' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'firm_name',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'firm_account_number',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'firm_address',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'solicitor_full_name',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'solicitor_reference_number',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
          ]
        )
      end
    end

    context 'with partial address' do
      let(:firm_office) { build(:firm_office, :valid, town: nil, postcode: nil) }
      let(:claim) { build(:claim, :firm_details, firm_office:) }

       it 'only includes the missing data tag once in the address' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'firm_name',
              text: 'Firm A'
            },
            {
              head_key: 'firm_account_number',
              text: '123ABC'
            },
            {
              head_key: 'firm_address',
              text: '2 Laywer Suite<br><strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'solicitor_full_name',
              text: 'Richard Jenkins'
            },
            {
              head_key: 'solicitor_reference_number',
              text: '111222'
            },
          ]
        )
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
