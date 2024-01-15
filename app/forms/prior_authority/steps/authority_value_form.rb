module PriorAuthority
  module Steps
    class AuthorityValueForm < ::Steps::BaseFormObject
      attribute :authority_value, :boolean
      validates :authority_value, inclusion: { in: [true, false] }

      def persist!
        application.update!(attributes)
      end
    end
  end
end
