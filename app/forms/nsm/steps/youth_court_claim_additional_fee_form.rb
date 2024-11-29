# this is a form to determine where to move to the equality questions
# or skip them, as such it does not persist anything to DB
module Nsm
  module Steps
    class YouthCourtClaimAdditionalFeeForm < ::Steps::BaseFormObject
      attribute :include_youth_court_fee, :boolean

      # Due to how Rails handles HTML forms with radio buttons that
      # can be blank, we can't use presence validation here
      validates :include_youth_court_fee, inclusion: { in: [true, false] }

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
