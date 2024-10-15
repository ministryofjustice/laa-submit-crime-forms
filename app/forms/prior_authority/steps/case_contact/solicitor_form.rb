module PriorAuthority
  module Steps
    module CaseContact
      class SolicitorForm < ::Steps::BaseFormObject
        attribute :contact_first_name, :string
        attribute :contact_last_name, :string
        attribute :contact_email, :string

        validates :contact_first_name, presence: true
        validates :contact_last_name, presence: true
        validates :contact_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
        validates :contact_email, presence: true, format: { with: RegularExpressions::EMAIL_DOMAIN_REGEXP }

        private

        def persist!
          solicitor = application.solicitor || application.build_solicitor
          solicitor.update!(attributes)
        end
      end
    end
  end
end
