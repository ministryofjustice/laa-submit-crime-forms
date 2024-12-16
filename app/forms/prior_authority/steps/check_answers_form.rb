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
        unless application.draft? || application.sent_back?
          errors.add(:base, :application_already_submitted)
          return false
        end

        application.update!(state: new_state)
        update_incorrect_information if application.correction_needed?
        SubmitToAppStore.new.perform(submission: application)

        true
      end

      def update_incorrect_information
        latest_incorrect_info = application.incorrect_informations.order(requested_at: :desc).first
        latest_incorrect_info.update(sections_changed: changes_made_since_request)
      end

      def application_corrected
        errors.add(:base, :application_not_corrected) unless application_changed_since_request?
      end

      def application_changed_since_request?
        changes_made_since_request.present?
      end

      def changes_made_since_request
        @changes_made_since_request ||= ::PriorAuthority::ChangeLister.call(
          application,
          SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application:).data
        )
      end

      def needs_correcting?
        application.sent_back? && application.correction_needed?
      end

      def new_state
        application.sent_back? ? :provider_updated : :submitted
      end
    end
  end
end
