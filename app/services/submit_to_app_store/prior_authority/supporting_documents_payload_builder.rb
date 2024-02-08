class SubmitToAppStore
  module PriorAuthority
    class SupportingDocumentsPayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.supporting_documents.map do |document|
          document.as_json(only: %i[file_name
                                    file_type
                                    file_size
                                    file_path
                                    document_type])
        end
      end
    end
  end
end
