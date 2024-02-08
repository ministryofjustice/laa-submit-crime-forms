class SubmitToAppStore
  module PriorAuthority
    class SolicitorPayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.solicitor.as_json(only: %i[
                                         full_name
                                         reference_number
                                         contact_full_name
                                         contact_email
                                       ])
      end
    end
  end
end
