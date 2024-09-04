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
        attributes.merge(state: new_state,
                         laa_reference: laa_reference)
      end

      def laa_reference
        return application.laa_reference if application.laa_reference.present?

        loop do
          proposed_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
          break proposed_reference unless PriorAuthorityApplication.exists?(laa_reference: proposed_reference)
        end
      end

      def new_state
        application.pre_draft? ? :draft : application.state
      end
    end
  end
end
