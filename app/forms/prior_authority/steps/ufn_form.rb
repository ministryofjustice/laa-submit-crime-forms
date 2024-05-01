module PriorAuthority
  module Steps
    class UfnForm < ::Steps::BaseFormObject
      attribute :ufn, :string
      validates :ufn, presence: true, ufn: true

      private

      def persist!
        application.update!(extended_attributes)
      end

      def extended_attributes
        attributes.merge(status: new_status,
                         laa_reference: generate_laa_reference)
      end

      def generate_laa_reference
        loop do
          proposed_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
          break proposed_reference unless PriorAuthorityApplication.exists?(laa_reference: proposed_reference)
        end
      end

      def new_status
        application.pre_draft? ? :draft : application.status
      end
    end
  end
end
