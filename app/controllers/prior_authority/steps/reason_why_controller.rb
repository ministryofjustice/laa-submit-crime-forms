module PriorAuthority
  module Steps
    class ReasonWhyController < BaseController
      include MultiFileUploadable

      def edit
        @form_object = ReasonWhyForm.build(
          current_application
        )
      end

      def update
        update_and_advance(ReasonWhyForm, as:, after_commit_redirect_path:)
      end

      def destroy
        evidence = current_application.supporting_documents.find_by(id: params[:evidence_id])
        file_uploader.destroy(evidence.file_path)
        evidence.destroy

        return_success({ deleted: true })
      rescue StandardError => e
        return_error('shared.shared_upload_errors.unable_delete', e)
      end

      private

      def record
        current_application
      end

      def as
        :reason_why
      end
    end
  end
end
