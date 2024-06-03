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

      def update_application
        unless application.draft? || application.sent_back?
          errors.add(:base, :application_already_submitted)
          return false
        end

        application.update!(attributes.merge({ status: new_status }))
        update_incorrect_information if application.incorrect_information_explanation.present?
        SubmitToAppStore.perform_later(submission: application)
        true
      end

      def update_incorrect_information
        builder = SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application:)
        events = SubmitToAppStore::PriorAuthority::EventBuilder.new(application, builder.data)
        sections_changed = events.corrected_info

        latest_incorrect_info = application.incorrect_informations.order(requested_at: :desc).first
        latest_incorrect_info.update(sections_changed:)
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
