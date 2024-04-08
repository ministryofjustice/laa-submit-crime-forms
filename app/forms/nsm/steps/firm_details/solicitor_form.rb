module Nsm
  module Steps
    module FirmDetails
      class SolicitorForm < ::Steps::BaseFormObject
        attribute :first_name, :string
        attribute :last_name, :string
        attribute :reference_number, :string
        attribute :contact_first_name, :string
        attribute :contact_last_name, :string
        attribute :contact_email, :string

        validates :first_name, presence: true
        validates :last_name, presence: true
        validates :reference_number, presence: true

        with_options if: :alternative_contact_details? do
          validates :contact_first_name, presence: true
          validates :contact_last_name, presence: true
          validates :contact_email, presence: true, format: { with: /\A.*@.*\..*\z/ }
        end

        def alternative_contact_details
          return @alternative_contact_details unless @alternative_contact_details.nil?

          [contact_last_name, contact_first_name, contact_email].any?(&:present?) ? YesNoAnswer::YES : YesNoAnswer::NO
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
            'contact_first_name' => nil,
            'contact_last_name' => nil,
            'contact_email' => nil,
          )
        end
      end
    end
  end
end
