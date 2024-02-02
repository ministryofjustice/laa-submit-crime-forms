require 'rails_helper'

RSpec.describe SubmitToAppStore::PriorAuthorityPayloadBuilder do
  subject { described_class.new(application:) }

  let(:expected_output) do
    {
      application: {
        prison_law: true,
        ufn: '123123/123',
        laa_reference: 'LAA-n4AohV',
        status: 'pre_draft',
        reason_why: 'something',
        main_offence: 'something',
        client_maat_number: '123',
        client_detained: true,
        client_detained_prison: 'something',
        subject_to_poca: true,
        next_hearing_date: '2024-01-16',
        plea: 'something',
        court_type: 'central_criminal_court',
        youth_court: true,
        psychiatric_liaison: false,
        psychiatric_liaison_reason_not: 'whatever you like',
        next_hearing: true,
        office_code: '1A123B',
        defendant: {
          first_name: 'bob',
          last_name: 'jim',
          maat: 'AA1'
        },
        firm_office: {
          account_number: '123ABC',
          address_line_1: '2 Laywer Suite',
          address_line_2: nil,
          name: 'Firm A',
          postcode: 'CR0 1RE',
          town: 'Lawyer Town',
          vat_registered: 'yes'
        },
        provider: {
          description: nil,
          email: 'provider@example.com'
        },
        solicitor: {
          contact_email: 'james@email.com',
          contact_full_name: 'James Blake',
          full_name: 'Richard Jenkins',
          reference_number: '111222'
        },
        supporting_documents: [
          {
            document_type: 'supporting_document',
            file_name: 'test.png',
            file_path: 'test_path',
            file_size: 1234,
            file_type: 'image/png'
          },
          {
            document_type: 'supporting_document',
            file_name: 'test.png',
            file_path: 'test_path',
            file_size: 1234,
            file_type: 'image/png'
          }
        ],
        quotes: [
          {
            service_type: 'Forensics Expert',
            custom_service_name: nil,
            contact_full_name: 'Joe Bloggs',
            organisation: 'LAA',
            postcode: 'CR0 1RE',
            primary: true
          }
        ]
      },
      application_id: application.id,
      application_state: 'submitted',
      application_type: 'crm4',
      json_schema_version: 1
    }
  end
  let(:provider) { create(:provider) }
  let(:application) { create(:prior_authority_application, :full) }
  let(:fixed_arbitrary_date) { Date.new(2024, 1, 15) }

  before { travel_to(fixed_arbitrary_date) }

  it 'generates the payload for an application' do
    expect(subject.payload.with_indifferent_access).to eq(expected_output.with_indifferent_access)
  end
end
