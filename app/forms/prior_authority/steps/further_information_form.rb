module PriorAuthority
  module Steps
    class FurtherInformationForm < ::Steps::BaseFormObject
      attribute :information_supplied, :string

      validates :information_supplied, presence: true

      def explanation
        record.information_requested
      end

      delegate :supporting_documents, to: :record

      private

      def persist!
        record.update!(attributes)
      end
    end
  end
end
