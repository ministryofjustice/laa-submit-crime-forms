require 'rails_helper'

RSpec.describe SubmitToAppStore::PriorAuthorityPayloadBuilder do
  subject { described_class.new(application:) }

  let(:expected_output) do
    {
      application: {
        prison_law: true,
        ufn: '120423/123',
        laa_reference: 'LAA-n4AohV',
        status: 'pre_draft',
        reason_why: 'something',
        main_offence_id: 'something',
        custom_main_offence_name: nil,
        client_detained: true,
        prison_id: 'something',
        custom_prison_name: nil,
        subject_to_poca: true,
        next_hearing_date: '2024-01-16',
        rep_order_date: nil,
        plea: 'something',
        court_type: 'central_criminal_court',
        youth_court: true,
        psychiatric_liaison: false,
        psychiatric_liaison_reason_not: 'whatever you like',
        next_hearing: true,
        office_code: '1A123B',
        service_type: 'pathologist_report',
        custom_service_name: nil,
        prior_authority_granted: false,
        no_alternative_quote_reason: 'a reason',
        confirm_excluding_vat: true,
        confirm_travel_expenditure: true,
        defendant: hash_including(
          first_name: an_instance_of(String),
          last_name: an_instance_of(String),
          maat: '1234',
          date_of_birth: /\A\d{4}-\d{2}-\d{2}\z/
        ),
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
          contact_first_name: 'James',
          contact_last_name: 'Blake',
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
            contact_first_name: 'Joe',
            contact_last_name: 'Bloggs',
            organisation: 'LAA',
            postcode: 'CR0 1RE',
            primary: true,
            cost_type: 'per_hour',
            cost_per_hour: '10.0',
            period: 180,
            cost_per_item: nil,
            items: nil,
            item_type: 'item',
            ordered_by_court: nil,
            related_to_post_mortem: true,
            id: application.primary_quote.id,
            document: {
              document_type: 'quote_document',
              file_name: 'test.png',
              file_path: 'test_path',
              file_size: 1234,
              file_type: 'image/png'
            },
            travel_cost_per_hour: '50.0',
            travel_cost_reason: nil,
            travel_time: 150,
            additional_cost_list: nil,
            additional_cost_total: nil,
          },
          {
            contact_first_name: 'Joe',
            contact_last_name: 'Bloggs',
            organisation: 'LAA',
            postcode: 'CR0 1RE',
            primary: false,
            cost_type: 'per_hour',
            cost_per_hour: '10.0',
            period: 180,
            cost_per_item: nil,
            items: nil,
            item_type: 'item',
            ordered_by_court: nil,
            related_to_post_mortem: true,
            id: application.alternative_quotes.first.id,
            document: nil,
            travel_cost_per_hour: '50.0',
            travel_cost_reason: nil,
            travel_time: 150,
            additional_cost_list: nil,
            additional_cost_total: nil,
          }
        ],
        additional_costs: [],
        further_informations: [
          {
            caseworker_id: '87e88ac6-d89a-4180-80d4-e03285023fb0',
            documents: [
              {
                file_name: 'further_info1.pdf',
                file_size: 1234,
                file_path: 'test_path',
                file_type: 'image/png',
                document_type: 'supporting_document'
              },
              {
                file_name: 'further_info2.pdf',
                file_size: 1234,
                file_path: 'test_path',
                file_type: 'image/png',
                document_type: 'supporting_document'
              }
            ],
            information_requested: 'please provider further evidence',
            information_supplied: 'here is the extra information you requested',
            requested_at: DateTime.new(2024, 1, 1, 1, 1, 1),
          }
        ]
      },
      application_id: application.id,
      application_state: 'submitted',
      application_type: 'crm4',
      json_schema_version: 1,
      application_risk: 'N/A',
      events: []
    }
  end
  let(:provider) { create(:provider) }
  let(:application) { create(:prior_authority_application, :full, :with_confirmations) }
  let(:fixed_arbitrary_date) { Date.new(2024, 1, 15) }

  before do
    travel_to(fixed_arbitrary_date)
    allow(SubmitToAppStore::PriorAuthority::EventBuilder).to receive(:call).and_return([])
  end

  it 'generates the payload for an application' do
    check_json(subject.payload.deep_symbolize_keys).matches(expected_output)
  end
end
