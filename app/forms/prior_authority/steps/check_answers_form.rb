module PriorAuthority
  module Steps
    class CheckAnswersForm < ::Steps::BaseFormObject
      attribute :confirm_excluding_vat, :boolean
      attribute :confirm_travel_expenditure, :boolean

      validates :confirm_excluding_vat, acceptance: { accept: true }, allow_nil: false
      validates :confirm_travel_expenditure, acceptance: { accept: true }, allow_nil: false

      # Do not save confirmations if "Save and come back later" - commit_draft
      def save!; end

      def persist!
        application.update!(attributes.merge({ status: :submitted }))
        SubmitToAppStore.new.process(submission: application)
        true
      end
    end
  end
end
