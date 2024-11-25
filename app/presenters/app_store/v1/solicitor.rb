module AppStore
  module V1
    class Solicitor < AppStore::V1::Base
      attribute :reference_number, :string
      attribute :contact_first_name, :string
      attribute :contact_last_name, :string
      attribute :contact_email, :string
      attribute :first_name, :string
      attribute :last_name, :string

      def contact_full_name
        "#{contact_first_name} #{contact_last_name}"
      end
    end
  end
end
