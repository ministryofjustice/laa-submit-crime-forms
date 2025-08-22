class SubmitToAppStore
  class PriorAuthorityPayloadBuilder
    def initialize(application:)
      @application = application
    end

    def payload
      { application_id: application.id,
        json_schema_version: 1,
        application_state: application.state,
        application: validated_data,
        application_type: 'crm4',
        events: PriorAuthority::EventBuilder.call(application) }
    end

    def validated_data
      built_data = data
      issues = LaaCrimeFormsCommon::Validator.validate(:prior_authority, built_data)
      raise "Validation issues detected for #{application.id}: #{issues.to_sentence}" if issues.any?

      data
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
        status:,
      )
    end

    DIRECT_ATTRIBUTES = %i[
      office_code
      prison_law
      ufn
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
      created_at
      updated_at
    ].freeze

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

    def status
      application.state
    end
  end
end
