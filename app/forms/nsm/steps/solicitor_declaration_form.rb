module Nsm
  module Steps
    class SolicitorDeclarationForm < ::Steps::BaseFormObject
      attribute :signatory_name, :string
      validates :signatory_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }

      private

      def persist!
        Claim.transaction do
          application.state = new_state
          if application.state == 'submitted'
            application.update_work_item_positions!
            application.update_disbursement_positions!
          end
          application.update!(attributes)
        end

        SubmitToAppStore.perform_later(submission: application)
        true
      end

      def new_state
        if application.state == 'draft'
          :submitted
        elsif application.state == 'sent_back' && FeatureFlags.nsm_rfi_loop.enabled?
          :provider_updated
        end
      end
    end
  end
end
