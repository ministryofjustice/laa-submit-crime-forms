# NOTE: FurtherInformationController and FurtherInformationForm has almost complete shared functionality
# between Prior Authority and Non-standard Magistrates, but we are not DRYing out the code intentionally
# to allow more flexibility for the processes to deviate if needed
module Nsm
  module Steps
    class FurtherInformationController < Nsm::Steps::BaseController
      include MultiFileUploadable

      skip_before_action :update_viewed_steps, :prune_viewed_steps

      def edit
        @form_object = FurtherInformationForm.build(record, application: current_application)
      end

      def update
        update_and_advance(FurtherInformationForm, as:, record:)
      end

      def destroy
        evidence = record.supporting_documents.find_by(id: params[:evidence_id])
        file_uploader.destroy(evidence.file_path)
        evidence.destroy

        return_success({ deleted: true })
      rescue StandardError => e
        return_error('shared.shared_upload_errors.unable_delete', e)
      end

      private

      def record
        current_application.pending_further_information.local_record
      end

      def as
        :nsm_further_information
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
