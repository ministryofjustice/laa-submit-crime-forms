module PriorAuthority
  module Steps
    class FurtherInformationController < BaseController
      include MultiFileUploadable

      def edit
        @form_object = FurtherInformationForm.build(record, application: current_application)
      end

      def update
        update_and_advance(FurtherInformationForm, as:, after_commit_redirect_path:, record:)
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
        current_application.pending_further_information
      end

      def as
        :further_information
      end

      def step_valid?
        current_application.sent_back? && current_application.further_information_needed?
      end
    end
  end
end
