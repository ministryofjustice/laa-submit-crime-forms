module PriorAuthority
  module Steps
    module CaseContact
      class FirmDetailForm < ::Steps::BaseFormObject
        attribute :name, :string
        attribute :account_number, :string

        validates :name, presence: true
        validates :account_number, presence: true

        private

        # We want to reuse the Office record between applications,
        # however if any details are changed, this should not affect
        # existing records, as such in this case we create a new record
        def persist!
          existing = application.firm_office || FirmOffice.latest.find_by(account_number:)
          existing&.assign_attributes(attributes)

          if existing.nil? || existing.changed?
            application.create_firm_office!(attributes)
            application.save!
          else
            application.update!(firm_office: existing)
          end
        end
      end
    end
  end
end
