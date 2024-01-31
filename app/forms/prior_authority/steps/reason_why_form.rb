module PriorAuthority
  module Steps
    class ReasonWhyForm < ::Steps::BaseFormObject
      attribute :reason_why, :string
      validates :reason_why, presence: true

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
