module PriorAuthority
  module Steps
    class ClientDetailForm < ::Steps::BaseFormObject
      attribute :first_name, :string
      attribute :last_name, :string
      attribute :date_of_birth, :multiparam_date

      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :date_of_birth, presence: true, multiparam_date: { allow_past: true, allow_future: false }

      private

      def persist!
        record.update!(attributes)
      end
    end
  end
end
