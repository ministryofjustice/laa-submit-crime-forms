module Nsm
  module Steps
    class SolicitorDeclarationForm < ::Steps::BaseFormObject
      attribute :signatory_name, :string
      validates :signatory_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }

      def persist!
        Claim.transaction do
          update_application
          SubmitToAppStore.new.perform(submission: application)
        end
        true
      end

      def new_state
        if application.state == 'draft'
          :submitted
        elsif application.state == 'sent_back'
          :provider_updated
        else
          raise 'Invalid state for claim submission'
        end
      end

      def update_application
        application.state = new_state
        if application.submitted?
          application.update_work_item_positions!
          application.update_disbursement_positions!
          application.update!(attributes)
        elsif application.provider_updated?
          application.pending_further_information.update!(attributes)
        # :nocov:
        else
          false
        end
        # :nocov:
        application.save!
      end
    end
  end
end
