module PriorAuthority
  module Steps
    class CheckAnswersForm < ::Steps::BaseFormObject
      attribute :confirm_excluding_vat, :boolean
      attribute :confirm_travel_expenditure, :boolean

      validates :confirm_excluding_vat, acceptance: { accept: true }, allow_nil: false
      validates :confirm_travel_expenditure, acceptance: { accept: true }, allow_nil: false

      validate :application_corrected, if: :needs_correcting?

      # Do not call persist! if "Save and come back later" - commit_draft
      def save!; end

      def persist!
        application.update!(attributes.merge({ status: new_status }))
        SubmitToAppStore.new.process(submission: application)
        true
      end

      def application_corrected
        errors.add(:base, :application_not_corrected) unless application_changed_since_request?
      end

      def application_changed_since_request?
        last_updated_at > application.resubmission_requested
      end

      def last_updated_at
        LastUpdateFinder.call(application)
      end

      def needs_correcting?
        application.sent_back? &&
          application.incorrect_information_explanation.present?
      end

      def new_status
        application.sent_back? ? :provider_updated : :submitted
      end
    end
  end
end
