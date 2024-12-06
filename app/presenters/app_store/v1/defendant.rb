module AppStore
  module V1
    class Defendant < AppStore::V1::Base
      attribute :first_name, :string
      attribute :last_name, :string
      attribute :maat, :string
      attribute :date_of_birth, :date
      attribute :main, :boolean

      def full_name
        [first_name, last_name].join(' ')
      end
    end
  end
end
