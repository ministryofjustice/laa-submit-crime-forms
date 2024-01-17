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
        Rails.logger.debug record
        Rails.logger.debug application
        record.update!(attributes)
        application.update!(extended_attributes)
      end

      def extended_attributes
        attributes.merge(client_detail_form_status: :complete)
      end
    end
  end
end
