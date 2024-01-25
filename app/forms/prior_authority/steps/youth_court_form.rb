module PriorAuthority
  module Steps
    class YouthCourtForm < ::Steps::BaseFormObject
      attribute :youth_court, :boolean
      validates :youth_court, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
