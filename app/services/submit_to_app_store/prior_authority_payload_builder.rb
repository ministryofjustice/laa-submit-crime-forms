class SubmitToAppStore
  class PriorAuthorityPayloadBuilder
    def initialize(application:)
      @application = application
    end

    def payload
      {
        application_id: application.id,
        json_schema_version: 1,
        application_state: 'submitted',
        application: data,
        application_type: 'crm4'
      }
    end

    private

    attr_reader :application

    def data
      direct_attributes.merge(
        supporting_documents:,
        provider:,
        firm_office:,
        solicitor:,
        defendant:,
      )
    end

    def direct_attributes
      application.as_json(only: DIRECT_ATTRIBUTES)
    end

    def supporting_documents
      application.supporting_documents.map do |document|
        document.as_json(only: %i[
                           file_name
                           file_type
                           file_size
                           file_path
                           document_type
                         ])
      end
    end

    def provider
      application.provider.as_json(only: %i[
                                     email
                                     description
                                   ])
    end

    def firm_office
      application.firm_office.as_json(only: %i[
                                        name
                                        account_number
                                        address_line_1
                                        address_line_2
                                        town
                                        postcode
                                        vat_registered
                                      ])
    end

    def solicitor
      application.solicitor.as_json(only: %i[
                                      full_name
                                      reference_number
                                      contact_full_name
                                      contact_email
                                    ])
    end

    def defendant
      application.defendant.as_json(only: %i[
                                      maat
                                      first_name
                                      last_name
                                    ])
    end

    DIRECT_ATTRIBUTES = %i[
      office_code
      prison_law
      ufn
      laa_reference
      status
      rep_order_data
      client_maat_number
      reason_why
      main_offence
      client_detained
      client_detained_prison
      subject_to_poca
      next_hearing_date
      plea
      court_type
      youth_court
      psychiatric_liaison
      psychiatric_liaison_reason_not
      next_hearing
    ].freeze
  end
end
