module PriorAuthority
  module Steps
    class PsychiatricLiaisonForm < ::Steps::BaseFormObject
      attribute :psychiatric_liaison, :boolean
      attribute :psychiatric_liaison_reason_not, :string

      validates :psychiatric_liaison, inclusion: { in: [true, false] }
      validates :psychiatric_liaison_reason_not, presence: true, if: :reason_required?

      private

      def reason_required?
        !psychiatric_liaison.nil? && !psychiatric_liaison
      end

      def persist!
        application.update!(attributes)
      end
    end
  end
end
