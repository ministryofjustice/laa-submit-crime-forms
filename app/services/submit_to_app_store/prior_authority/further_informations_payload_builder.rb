class SubmitToAppStore
  module PriorAuthority
    class FurtherInformationsPayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.further_informations.map do |further_information|
          further_information.as_json(only: ATTRIBUTES).merge(
            documents: documents(further_information)
          )
        end
      end

      def documents(further_information)
        further_information.supporting_documents.map do |document|
          document.as_json(only: %i[file_name
                                    file_type
                                    file_size
                                    file_path
                                    document_type])
        end
      end

      ATTRIBUTES = %i[information_requested
                      information_supplied
                      caseworker_id
                      requested_at].freeze
    end
  end
end
