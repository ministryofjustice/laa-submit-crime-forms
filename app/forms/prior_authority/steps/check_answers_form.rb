module PriorAuthority
  module Steps
    class CheckAnswersForm < ::Steps::BaseFormObject
      attribute :confirm_excluding_vat, :boolean
      attribute :confirm_travel_expenditure, :boolean

      validates :confirm_excluding_vat, acceptance: { accept: true }, allow_nil: false
      validates :confirm_travel_expenditure, acceptance: { accept: true }, allow_nil: false

      def persist!
        application.update!(attributes)

        # TODO: actually submit to app store
        PriorAuthorityApplication.transaction do
          application.status = :submitted
          application.update!(attributes)
          # SubmitToAppStore.new.process(submission: application)
        end
      end
    end
  end
end
