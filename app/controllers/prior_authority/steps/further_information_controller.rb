module PriorAuthority
  module Steps
    class FurtherInformationController < BaseController
      def edit
        @form_object = FurtherInformationForm.build(record, application: current_application)
        @explanation = record.information_requested
      end

      def update
        @supporting_documents = record.supporting_documents
        update_and_advance(FurtherInformationForm, as:, after_commit_redirect_path:, record:)
      end



      def create
        unless supported_filetype(params[:documents])
          return return_error(nil,
                              { message: t('activemodel.errors.messages.forbidden_document_type') })
        end

        evidence = upload_file(params)
        return_success({ evidence_id: evidence.id, file_name: params[:documents].original_filename })
      rescue FileUpload::FileUploader::PotentialMalwareError => e
        return_error(e, { message: t('activemodel.errors.messages.suspected_malware') })
      rescue StandardError => e
        return_error(e, { message: t('activemodel.errors.messages.upload_failed') })
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

      def additional_permitted_params
        %i[information_supplied]
      end
    end
  end
end
