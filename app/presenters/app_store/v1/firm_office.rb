module AppStore
  module V1
    class FirmOffice < AppStore::V1::Base
      attribute :name, :string
      attribute :address_line_1, :string
      attribute :address_line_2, :string
      attribute :town, :string
      attribute :postcode, :string
      attribute :vat_registered, :string
    end
  end
end
