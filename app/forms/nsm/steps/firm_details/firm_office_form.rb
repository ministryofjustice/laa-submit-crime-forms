module Steps
  module FirmDetails
    class FirmOfficeForm < Steps::BaseFormObject
      attribute :name, :string
      attribute :account_number, :string
      attribute :address_line_1, :string
      attribute :address_line_2, :string
      attribute :town, :string
      attribute :postcode, :string
      attribute :vat_registered, :value_object, source: YesNoAnswer

      validates :name, presence: true
      validates :account_number, presence: true
      validates :address_line_1, presence: true
      validates :town, presence: true
      validates :postcode, presence: true, uk_postcode: true
      validates :vat_registered, presence: true, inclusion: { in: YesNoAnswer.values }

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
