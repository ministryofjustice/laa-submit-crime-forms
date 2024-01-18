module PriorAuthority
  module Steps
    module CaseContact
      class SolicitorForm < ::Steps::BaseFormObject
        attribute :contact_full_name, :string
        attribute :contact_email, :string

        validates :contact_full_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }
        validates :contact_email, presence: true, format: { with: /\A.*@.*\..*\z/ }

        private

        def persist!
          existing = application.solicitor
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
end
