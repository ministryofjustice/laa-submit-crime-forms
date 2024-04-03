module PriorAuthority
  module Steps
    class FurtherInformationForm < ::Steps::BaseFormObject
      attribute :information_supplied, :string

      validates :information_supplied, presence: true

      def explanation
        record.information_requested
      end

      def supporting_documents
        record.supporting_documents
      end

      private

      def persist!
        record.update!(attributes)
      end
    end
  end
end
