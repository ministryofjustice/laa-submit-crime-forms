module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      attribute :primary_service, :value_object, source: PriorAuthorityServices

      validates :primary_service, inclusionL { in: PriorAuthorityServices.values }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
