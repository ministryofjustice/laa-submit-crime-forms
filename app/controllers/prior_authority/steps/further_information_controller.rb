module PriorAuthority
  module Steps
    class FurtherInformationController < BaseController
      include MultiFileUploadable

      def edit
        @form_object = FurtherInformationForm.build(record, application: current_application)
        @explanation = record.information_requested
        @supporting_documents = record.supporting_documents
      end

      def update
        @supporting_documents = record.supporting_documents
        update_and_advance(FurtherInformationForm, as:, after_commit_redirect_path:, record:)
      end

      def destroy
        evidence = record.supporting_documents.find_by(id: params[:evidence_id])
        file_uploader.destroy(evidence.file_path)
        evidence.destroy

        return_success({ deleted: true })
      rescue StandardError => e
        return_error(e, { message: t('shared.shared_upload_errors.unable_delete') })
      end

      private

      def record
        current_application.further_informations.last
      end

      def as
        :further_information
      end
    end
  end
end
