class SubmitToAppStore
  module PriorAuthority
    class IncorrectInformationsPayloadBuilder
      ATTRIBUTES = %i[information_requested
                      sections_changed
                      caseworker_id
                      requested_at].freeze

      def initialize(application)
        @application = application
      end

      def payload
        @application.incorrect_informations.map do |incorrect_info|
          incorrect_info.as_json(only: ATTRIBUTES)
      end
    end
  end
end
