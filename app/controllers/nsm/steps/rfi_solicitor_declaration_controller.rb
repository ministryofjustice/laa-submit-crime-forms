module Nsm
  module Steps
    class RfiSolicitorDeclarationController < Nsm::Steps::BaseController
      skip_before_action :update_viewed_steps, :prune_viewed_steps
      def edit
        @form_object = SolicitorDeclarationForm.build(
          record,
          application: current_application
        )
      end

      def update
        update_and_advance(SolicitorDeclarationForm, as: :solicitor_declaration, record: record)
      end

      private

      def record
        current_application.pending_further_information.local_record
      end

      def step_valid?
        current_application.sent_back?
      end

      def current_application
        @current_application ||= AppStoreDetailService.nsm(params[:id], current_provider)
      end
    end
  end
end
