module PriorAuthority
  module Steps
    class PrimaryQuoteForm < ::Steps::BaseFormObject
      attribute :primary_service, :string

      validates :primary_service, presence: true, inclusion: { in: QuoteService.all }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
