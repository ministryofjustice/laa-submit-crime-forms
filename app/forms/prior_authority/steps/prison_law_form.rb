module PriorAuthority
  module Steps
    class PrisonLawForm < ::Steps::BaseFormObject
      attribute :prison_law, :boolean
      validates :prison_law, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
