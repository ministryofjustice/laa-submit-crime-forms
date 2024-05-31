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
        application.with_lock do
          update_application
        end
      end

      # NOTE: POtential race condition when `SubmitToAppStore` started before the lock is released
      # have resolved this by retrying in AppStoreClient#post when existing ID, due to risk
      # moving the sidekiq caller out of the transaction as unsure if this would introduce other
      # errors
      def update_application
        unless application.draft? || application.sent_back?
          errors.add(:base, :application_already_submitted)
          return false
        end

        application.update!(attributes.merge({ status: new_status }))
        SubmitToAppStore.perform_later(submission: application)
        true
      end

      def application_corrected
        errors.add(:base, :application_not_corrected) unless application_changed_since_request?
      end

      def application_changed_since_request?
        content = SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application:).data
        ::PriorAuthority::ChangeLister.call(application, content).present?
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
