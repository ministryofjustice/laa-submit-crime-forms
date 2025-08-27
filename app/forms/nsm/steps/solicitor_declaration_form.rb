module Nsm
  module Steps
    class SolicitorDeclarationForm < ::Steps::BaseFormObject
      attribute :signatory_name, :string
      validates :signatory_name, presence: true, format: { with: /\A[a-z,.'-]+( +[a-z,.'-]+)+\z/i }

      def persist!
        Claim.transaction do
          update_application
          SubmitToAppStore.new.perform(submission: application)
        end
        true
      end

      def update_application
        if application.draft?
          application.update_work_item_positions!
          application.update_disbursement_positions!
          application.update!(attributes.merge(state: :submitted))
        elsif application.sent_back?
          application.pending_further_information.update!(attributes)
          application.provider_updated!
        else
          raise 'Invalid state for claim submission'
        end
      end
    end
  end
end
