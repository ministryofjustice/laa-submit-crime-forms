class SubmitToAppStore
  module PriorAuthority
    class EventBuilder
      def self.call(application, new_data)
        new(application, new_data).payload
      end

      def initialize(application, new_data)
        @application = application
        @new_data = new_data.deep_stringify_keys
      end

      def payload
        return [] unless @application.provider_updated?

        [
          {
            id: SecureRandom.uuid,
            event_type: 'provider_updated',
            details: {
              comment: further_information_comment,
              documents: further_information_documents,
              corrected_info: corrected_info
            },
          }
        ]
      end

      def corrected_info
        ::PriorAuthority::ChangeLister.call(@application, @new_data)
      end

      def further_information_comment
        return unless further_information_supplied(@application)

        @application.further_informations
                    .order(:created_at).last.information_supplied
      end

      def further_information_documents
        if further_information_supplied(@application)
          @application.further_informations
                      .order(:created_at).last.supporting_documents
        else
          []
        end
      end

      def further_information_supplied(application)
        if application.further_informations.empty?
          false
        else
          last_further_info = application.further_informations.order(:created_at).last.created_at
          application.provider_updated? && (last_further_info >= application.app_store_updated_at)
        end
      end
    end
  end
end
