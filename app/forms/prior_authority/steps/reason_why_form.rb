module PriorAuthority
  module Steps
    class ReasonWhyForm < ::Steps::BaseFormObject
      attribute :reason_why, :string
      validates :reason_why, presence: true, length: { maximum: 2000 }

      def supporting_documents
        application.supporting_documents
      end

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
