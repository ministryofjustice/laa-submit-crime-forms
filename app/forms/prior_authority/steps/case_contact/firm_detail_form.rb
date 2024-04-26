module PriorAuthority
  module Steps
    module CaseContact
      class FirmDetailForm < ::Steps::BaseFormObject
        attribute :name, :string
        validates :name, presence: true

        private

        def persist!
          record = application.firm_office || application.build_firm_office
          record.assign_attributes(attributes)
          record.save!
        end
      end
    end
  end
end
