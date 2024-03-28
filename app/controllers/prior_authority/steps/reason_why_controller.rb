module PriorAuthority
  module Steps
    class ReasonWhyController < BaseController
      skip_before_action :verify_authenticity_token, only: [:create, :destroy]

      def edit
        @form_object = ReasonWhyForm.build(
          current_application
        )

        @supporting_documents = current_application.supporting_documents
      end

      def update
        @supporting_documents = current_application.supporting_documents
        update_and_advance(ReasonWhyForm, as:, after_commit_redirect_path:)
      end

      def destroy
        evidence = current_application.supporting_documents.find_by(id: params[:evidence_id])
        file_uploader.destroy(evidence.file_path)
        evidence.destroy

        return_success({ deleted: true })
      rescue StandardError => e
        return_error(e, { message: t('shared.shared_upload_errors.unable_delete') })
      end

      private

      def as
        :reason_why
      end
    end
  end
end
