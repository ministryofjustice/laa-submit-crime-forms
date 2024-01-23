module Nsm
  module Steps
    module FirmDetails
      class SolicitorForm < ::Steps::BaseFormObject
        attribute :full_name, :string
        attribute :reference_number, :string
        attribute :contact_full_name, :string
        attribute :contact_email, :string

        validates :full_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }
        validates :reference_number, presence: true

        validates :contact_full_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i },
                                                      if: ->(form) { form.alternative_contact_details? }
        validates :contact_email, presence: true, format: { with: /\A.*@.*\..*\z/ },
                                                  if: ->(form) { form.alternative_contact_details? }

        def alternative_contact_details
          return @alternative_contact_details unless @alternative_contact_details.nil?

          contact_full_name.present? || contact_email.present? ? YesNoAnswer::YES : YesNoAnswer::NO
        end

        def alternative_contact_details=(val)
          @alternative_contact_details = YesNoAnswer.new(val) if YesNoAnswer.values.map(&:to_s).include?(val)
        end

        def alternative_contact_details?
          alternative_contact_details == YesNoAnswer::YES
        end

        private

        # We want to reuse the Solicitor record between applications,
        # however if any details are changed, this should not affect
        # existing records, as such in this case we create a new record
        def persist!
          existing = application.solicitor || Solicitor.latest.find_by(reference_number:)
          existing&.assign_attributes(attributes_with_resets)

          if existing.nil? || existing.changed?
            application.create_solicitor!(attributes_with_resets)
            application.save!
          else
            application.update!(solicitor: existing)
          end
        end

        def attributes_with_resets
          return attributes if alternative_contact_details?

          attributes.merge(
            'contact_full_name' => nil,
            'contact_email' => nil,
          )
        end
      end
    end
  end
end
