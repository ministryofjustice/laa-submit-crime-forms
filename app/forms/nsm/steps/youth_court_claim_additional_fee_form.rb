# this is a form to determine where to move to the equality questions
# or skip them, as such it does not persist anything to DB
module Nsm
  module Steps
    class YouthCourtClaimAdditionalFeeForm < ::Steps::BaseFormObject
      attribute :youth_court_fee_claimed, :boolean

      validates :youth_court_fee_claimed, presence: true, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
