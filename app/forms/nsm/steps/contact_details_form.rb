module Nsm
  module Steps
    class ContactDetailsForm < ::Steps::BaseFormObject
      attribute :contact_first_name, :string
      attribute :contact_last_name, :string
      attribute :contact_email, :string

      validates :contact_first_name, presence: true
      validates :contact_last_name, presence: true
      validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
      validates :contact_email, presence: true, format: { with: RegularExpressions::EMAIL_DOMAIN_REGEXP }

      private

      # We want to reuse the Solicitor record between applications,
      # however if any details are changed, this should not affect
      # existing records, as such in this case we create a new record
      # The exception is if we are adding contact details to a record for the first time,
      # in which case the record is changing, but we don't want to duplicate it
      def persist!
        application.solicitor.update!(attributes)
      end
    end
  end
end
