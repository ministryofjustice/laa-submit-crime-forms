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
      data = application.as_json(except: %i[id created_at updated_at])
      data.merge(
        supporting_documents:,
      )
    end

    def supporting_documents
      application.supporting_documents.map { _1.as_json(except: %i[id created_at updated_at]) }
    end
  end
end
