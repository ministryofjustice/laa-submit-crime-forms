class SubmitToAppStore
  class PriorAuthorityPayloadBuilder
    def initialize(application:)
      @application = application
    end

    def payload
      { application_id: application.id,
        json_schema_version: 1,
        application_state: 'submitted',
        application: data,
        application_type: 'crm4',
        application_risk: 'N/A' }
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
        quotes:,
        additional_costs:,
      ).merge(convenience_attributes)
    end

    def direct_attributes
      application.as_json(only: DIRECT_ATTRIBUTES)
    end

    def supporting_documents
      PriorAuthority::SupportingDocumentsPayloadBuilder.new(application).payload
    end

    def provider
      application.provider.as_json(only: %i[email description])
    end

    def firm_office
      PriorAuthority::FirmOfficePayloadBuilder.new(application).payload
    end

    def solicitor
      PriorAuthority::SolicitorPayloadBuilder.new(application).payload
    end

    def defendant
      application.defendant.as_json(only: %i[maat first_name last_name])
    end

    def quotes
      PriorAuthority::QuotePayloadBuilder.new(application).payload
    end

    def additional_costs
      PriorAuthority::AdditionalCostPayloadBuilder.new(application).payload
    end

    def convenience_attributes
      {
        firm_name: application.firm_office.name,
        client_name: application.defendant.full_name
      }
    end

    DIRECT_ATTRIBUTES = %i[
      office_code
      prison_law
      ufn
      laa_reference
      status
      rep_order_date
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
      service_type
      custom_service_name
      prior_authority_granted
      no_alternative_quote_reason
      confirm_excluding_vat
      confirm_travel_expenditure
    ].freeze
  end
end
