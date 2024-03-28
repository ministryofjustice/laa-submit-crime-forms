require 'rails_helper'

RSpec.describe SubmitToAppStore::PriorAuthority::EventBuilder do
  describe '.call' do
    let(:application) { create(:prior_authority_application, status:) }
    let(:new_data) do
      {
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
        defendant: {
          first_name: 'bob',
          last_name: 'jim',
          maat: 'AA1',
          date_of_birth: '1981-11-12'
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
        quotes: [primary_quote, alternative_quote, alternative_quote.merge(id: 'new-quote-id')],
        additional_costs: [
          {
            id: '555555',
            name: 'Some cost',
            description: 'Some description',
            unit_type: 'per_hour',
            cost_per_hour: 150.0,
            cost_per_item: nil,
            items: nil,
            period: 180,
          }
        ]
      }
    end

    let(:primary_quote) do
      {
        contact_full_name: 'Joe Bloggs',
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
        id: '123123123',
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
      }
    end

    let(:alternative_quote) do
      {
        contact_full_name: 'Joe Bloggs',
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
        id: '456456456',
        document: nil,
        travel_cost_per_hour: '50.0',
        travel_cost_reason: nil,
        travel_time: 150,
        additional_cost_list: nil,
        additional_cost_total: nil,
      }
    end

    context 'when application is in submitted state' do
      let(:status) { :submitted }

      it 'returns an empty array' do
        expect(described_class.call(application, new_data)).to eq []
      end
    end

    context 'when application is provider_updated' do
      let(:status) { :provider_updated }
      let(:dummy_client) { instance_double(AppStoreClient) }
      let(:old_data) { new_data.merge(changes).deep_stringify_keys }
      let(:listed_corrections) { described_class.call(application, new_data).first.dig(:details, :corrected_info) }

      before do
        allow(AppStoreClient).to receive(:new).and_return(dummy_client)
        allow(dummy_client).to receive(:get).and_return({ 'application' => old_data })
      end

      context 'when application has not changed' do
        let(:changes) { {} }

        it 'returns an event with no corrected info' do
          expect(described_class.call(application, new_data)).to eq(
            [
              {
                details: {
                  comment: 'TODO: Extract from latest further_information',
                  corrected_info: [],
                  documents: []
                },
                event_type: 'Event::ProviderUpdated'
              }
            ]
          )
        end
      end

      context 'when ufn has changed' do
        let(:changes) { { ufn: '120423/999' } }

        it 'lists the change' do
          expect(listed_corrections).to eq [:ufn]
        end
      end

      context 'when firm office detail has changed' do
        let(:changes) do
          {
            firm_office: {
              account_number: '123ABC',
              address_line_1: '3 Laywer Suite',
              address_line_2: nil,
              name: 'Firm A',
              postcode: 'CR0 1RE',
              town: 'Lawyer Town',
              vat_registered: 'yes'
            }
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq [:case_contact]
        end
      end

      context 'when solicitor detail has changed' do
        let(:changes) do
          {
            solicitor: {
              contact_email: 'james@email.com',
              contact_full_name: 'James Rake',
              full_name: 'Richard Jenkins',
              reference_number: '111222'
            },
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq [:case_contact]
        end
      end

      context 'when client non-maat detail has changed' do
        let(:changes) do
          {
            defendant: {
              first_name: 'rob',
              last_name: 'jim',
              maat: 'AA1',
              date_of_birth: '1981-11-12'
            },
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq [:client_detail]
        end
      end

      context 'when client maat has changed' do
        let(:changes) do
          {
            defendant: {
              first_name: 'bob',
              last_name: 'jim',
              maat: 'AA2',
              date_of_birth: '1981-11-12'
            },
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq [:case_detail]
        end
      end

      context 'when case detail has changed' do
        let(:changes) { { main_offence_id: 'something_else' } }

        it 'lists the change' do
          expect(listed_corrections).to eq [:case_detail]
        end
      end

      context 'when hearing detail has changed' do
        let(:changes) { { plea: 'something_else' } }

        it 'lists the change' do
          expect(listed_corrections).to eq [:hearing_detail]
        end
      end

      context 'when next hearing detail has changed' do
        let(:changes) { { next_hearing: false } }

        it 'lists the change' do
          expect(listed_corrections).to eq [:next_hearing]
        end
      end

      context 'when primary quote has changed' do
        let(:changes) do
          {
            quotes: [
              primary_quote.merge(organisation: 'other'),
              alternative_quote,
              alternative_quote.merge(id: 'new-quote-id')
            ]
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq [:primary_quote]
        end
      end

      context 'when primary quote-related attribute has changed' do
        let(:changes) { { service_type: 'other_service_type' } }

        it 'lists the change' do
          expect(listed_corrections).to eq [:primary_quote]
        end
      end

      context 'when additional costs have changed' do
        let(:changes) { { additional_costs: [] } }

        it 'lists the change' do
          expect(listed_corrections).to eq [:primary_quote]
        end
      end

      context 'when reason why fields changed' do
        let(:changes) do
          {
            supporting_documents: [
              {
                document_type: 'supporting_document',
                file_name: 'test5.png',
                file_path: 'test_path',
                file_size: 1234,
                file_type: 'image/png'
              },
            ],
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq [:reason_why]
        end
      end

      context 'when alternative quote has changed' do
        let(:changes) do
          {
            quotes: [
              primary_quote,
              alternative_quote.merge(period: 500),
              alternative_quote.merge(id: 'new-quote-id')
            ],
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq ['alternative_quote_1']
        end
      end

      context 'when no alternative quote reason has changed' do
        let(:changes) { { no_alternative_quote_reason: 'Some other reason' } }

        it 'lists the change' do
          expect(listed_corrections).to eq ['alternative_quote_1']
        end
      end

      context 'when alternative quote has been added' do
        let(:changes) do
          {
            quotes: [primary_quote,
                     alternative_quote],
          }
        end

        it 'lists the change' do
          expect(listed_corrections).to eq ['alternative_quote_2']
        end
      end
    end
  end
end
