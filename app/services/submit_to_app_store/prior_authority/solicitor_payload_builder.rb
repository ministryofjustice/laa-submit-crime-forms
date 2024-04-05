class SubmitToAppStore
  module PriorAuthority
    class SolicitorPayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.solicitor.as_json(only: %i[
                                         reference_number
                                         contact_first_name
                                         contact_last_name
                                         contact_email
                                       ])
      end
    end
  end
end
