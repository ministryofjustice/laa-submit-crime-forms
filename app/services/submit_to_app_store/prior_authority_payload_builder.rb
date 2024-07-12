class SubmitToAppStore
  class PriorAuthorityPayloadBuilder
    def initialize(application:, include_events: true)
      @application = application
      @include_events = include_events
    end

    def payload
      { application_id: application.id,
        json_schema_version: 1,
        application_state: application.status,
        application: data,
        application_type: 'crm4',
        application_risk: 'N/A',
        events: @include_events ? PriorAuthority::EventBuilder.call(application, data) : [] }
    end

    def data
      @data ||= direct_attributes.merge(
        supporting_documents:,
        provider:,
        firm_office:,
        solicitor:,
        defendant:,
        quotes:,
        additional_costs:,
        further_information:,
        incorrect_information:,
      )
    end

    private

    attr_reader :application

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
      application.defendant.as_json(only: %i[maat first_name last_name date_of_birth])
    end

    def quotes
      PriorAuthority::QuotePayloadBuilder.new(application).payload
    end

    def additional_costs
      PriorAuthority::AdditionalCostPayloadBuilder.new(application).payload
    end

    def further_information
      PriorAuthority::FurtherInformationsPayloadBuilder.new(application).payload
    end

    def incorrect_information
      PriorAuthority::IncorrectInformationsPayloadBuilder.new(application).payload
    end

    DIRECT_ATTRIBUTES = %i[
      office_code
      prison_law
      ufn
      laa_reference
      status
      rep_order_date
      reason_why
      main_offence_id
      custom_main_offence_name
      client_detained
      prison_id
      custom_prison_name
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
