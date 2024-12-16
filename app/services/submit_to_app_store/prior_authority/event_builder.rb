class SubmitToAppStore
  module PriorAuthority
    class EventBuilder
      def self.call(application)
        new(application).payload
      end

      def initialize(application)
        @application = application
      end

      def payload
        return [] unless @application.provider_updated?

        [
          {
            id: SecureRandom.uuid,
            event_type: 'provider_updated',
            details: {
              comment: further_information_comment,
              documents: further_information_documents || [],
              corrected_info: corrected_info
            },
          }
        ]
      end

      def corrected_info
        @application.pending_incorrect_information.present?
      end

      def further_information_comment
        @application.pending_further_information&.information_supplied
      end

      def further_information_documents
        @application.pending_further_information&.supporting_documents
      end
    end
  end
end
