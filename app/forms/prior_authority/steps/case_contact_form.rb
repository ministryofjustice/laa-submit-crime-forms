module PriorAuthority
  module Steps
    class CaseContactForm < ::Steps::BaseFormObject
      attribute :contact_name, :string
      attribute :contact_email, :string
      attribute :firm_name, :string
      attribute :firm_account_number, :string

      validates :contact_name, presence: true
      validates :contact_email, presence: true
      validates :firm_name, presence: true
      validates :firm_account_number, presence: true

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
