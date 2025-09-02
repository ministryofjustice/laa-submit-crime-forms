module Nsm
  module Steps
    module FirmDetails
      class FirmOfficeForm < ::Steps::BaseFormObject
        attribute :name, :string
        attribute :address_line_1, :string
        attribute :address_line_2, :string
        attribute :town, :string
        attribute :postcode, :string
        attribute :vat_registered, :value_object, source: YesNoAnswer

        validates :name, presence: true
        validates :address_line_1, presence: true
        validates :town, presence: true
        validates :postcode, presence: true, uk_postcode: true
        validates :vat_registered, presence: true, inclusion: { in: YesNoAnswer.values }

        private

        def persist!
          record = application.firm_office || application.build_firm_office
          record.update!(attributes)
          application.save!
        end
      end
    end
  end
end
