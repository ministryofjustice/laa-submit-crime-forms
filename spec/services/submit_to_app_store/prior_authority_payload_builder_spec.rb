require 'rails_helper'

RSpec.describe SubmitToAppStore::PriorAuthorityPayloadBuilder do
  subject(:builder) { described_class.new(application:) }

  let(:expected_output) do
    {
      application: {
        created_at: fixed_arbitrary_date.utc,
        updated_at: fixed_arbitrary_date.utc,
        prison_law: true,
        ufn: '120423/123',
        status: 'submitted',
        reason_why: 'something',
        main_offence_id: 'something',
        custom_main_offence_name: nil,
        client_detained: true,
        prison_id: 'something',
        custom_prison_name: nil,
        subject_to_poca: true,
        next_hearing_date: '2024-01-16',
        rep_order_date: nil,
        plea: 'guilty',
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
        defendant: hash_including(
          first_name: application.defendant.first_name,
          last_name: application.defendant.last_name,
          maat: application.defendant.maat,
          date_of_birth: application.defendant.date_of_birth.iso8601,
        ),
        firm_office: {
          account_number: '1A123B',
          address_line_1: nil,
          address_line_2: nil,
          name: 'Firm A',
          postcode: nil,
          town: nil,
          vat_registered: nil
        },
        provider: {
          description: nil,
          email: 'provider@example.com'
        },
        solicitor: {
          contact_email: 'james@email.com',
          contact_first_name: 'James',
          contact_last_name: 'Blake',
          reference_number: nil,
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
            town: 'Slough',
            postcode: 'CR0 1RE',
            primary: true,
            cost_type: 'per_hour',
            cost_per_hour: '10.0',
            period: 180,
            cost_per_item: nil,
            items: nil,
            item_type: 'item',
            cost_item_type: 'item',
            cost_multiplier: 1,
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
            travel_cost_reason: 'Reasons',
            travel_time: 150,
            additional_cost_list: nil,
            additional_cost_total: nil,
          },
          {
            contact_first_name: 'Joe',
            contact_last_name: 'Bloggs',
            organisation: 'LAA',
            town: 'Slough',
            postcode: 'CR0 1RE',
            primary: false,
            cost_type: 'per_hour',
            cost_per_hour: '10.0',
            period: 180,
            cost_per_item: nil,
            items: nil,
            item_type: 'item',
            cost_item_type: 'item',
            cost_multiplier: 1,
            ordered_by_court: nil,
            related_to_post_mortem: true,
            id: application.alternative_quotes.first.id,
            document: nil,
            travel_cost_per_hour: '50.0',
            travel_cost_reason: 'Reasons',
            travel_time: 150,
            additional_cost_list: nil,
            additional_cost_total: nil,
          }
        ],
        additional_costs: [],
        further_information: [
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
            information_requested: 'please provide further evidence',
            information_supplied: 'here is the extra information you requested',
            new: true,
            requested_at: DateTime.new(2024, 1, 1, 1, 1, 1).utc,
          }
        ],
        incorrect_information: [
          {
            caseworker_id: '87e88ac6-d89a-4180-80d4-e03285023fb0',
            information_requested: 'Please update the case details',
            new: true,
            requested_at: DateTime.new(2024, 1, 1, 1, 1, 1).utc,
            sections_changed: ['case_detail']
          }
        ],
      },
      application_id: application.id,
      application_state: 'submitted',
      application_type: 'crm4',
      json_schema_version: 1,
      events: []
    }
  end
  let(:provider) { create(:provider) }
  let(:application) do
    create(:prior_authority_application, :full, :with_further_information_supplied, :with_corrections, state: :submitted)
  end
  let(:fixed_arbitrary_date) { DateTime.new(2024, 1, 15, 0, 0, 0) }

  before do
    travel_to(fixed_arbitrary_date)
    allow(SubmitToAppStore::PriorAuthority::EventBuilder).to receive(:call).and_return([])
  end

  it 'generates the payload for an application' do
    check_json(builder.payload.deep_symbolize_keys).matches(expected_output)
  end

  context 'when there is a validation error' do
    before do
      allow(LaaCrimeFormsCommon::Validator).to receive(:validate).and_return(['The favourite_fruit field is missing'])
    end

    it 'raises the error' do
      expect { builder.payload }.to raise_error(
        "Validation issues detected for #{application.id}: The favourite_fruit field is missing"
      )
    end
  end
end
