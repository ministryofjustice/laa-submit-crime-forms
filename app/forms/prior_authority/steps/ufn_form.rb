module PriorAuthority
  module Steps
    class UfnForm < ::Steps::BaseFormObject
      include LaaCrimeFormsCommon::Validators

      attribute :ufn, :string
      validates :ufn, presence: true, ufn: true

      private

      def persist!
        application.update!(extended_attributes)
      end

      def extended_attributes
        attributes.merge(state: new_state)
      end

      def new_state
        application.pre_draft? ? :draft : application.state
      end
    end
  end
end
