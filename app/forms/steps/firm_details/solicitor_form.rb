require 'steps/base_form_object'

module Steps
  module FirmDetails
    class SolicitorForm < Steps::BaseFormObject
      attribute :full_name, :string
      attribute :reference_number, :string
      attribute :contact_full_name, :string
      attribute :contact_email, :string

      validates :full_name, presence: true
      validates :reference_number, presence: true
      validates :contact_full_name, presence: true
      validates :contact_email, presence: true

      private

      # We want to reuse the Solicitor record between applications,
      # however if any details are changed, this should not affect
      # existing records, as such in this case we create a new record
      def persist!
        existing = application.solicitor || Solicitor.latest.find_by(reference_number:)
        existing&.assign_attributes(attributes)

        if existing.nil? || existing.changed?
          application.create_solicitor!(attributes)
          application.save!
        else
          application.update!(solicitor: existing)
        end
      end
    end
  end
end
