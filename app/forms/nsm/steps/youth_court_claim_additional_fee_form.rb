# this is a form to determine where to move to the equality questions
# or skip them, as such it does not persist anything to DB
module Nsm
  module Steps
    class YouthCourtClaimAdditionalFeeForm < ::Steps::BaseFormObject
      attribute :claimed_include_youth_court_fee, :boolean

      validates :claimed_include_youth_court_fee, presence: true, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
