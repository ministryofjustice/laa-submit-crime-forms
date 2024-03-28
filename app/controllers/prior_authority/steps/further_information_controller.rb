module PriorAuthority
  module Steps
    class FurtherInformationController < BaseController
      skip_before_action :verify_authenticity_token, only: [:create, :destroy]

      def edit
        @form_object = FurtherInformationForm.build(record, application: current_application)
        @explanation = record.information_requested
        @supporting_documents = record.supporting_documents
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

      def file_uploader
        @file_uploader ||= FileUpload::FileUploader.new
      end

      def upload_file(params)
        file_path = file_uploader.upload(params[:documents])
        save_file(params[:documents], file_path)
      end

      def save_file(params, file_path)
        record.supporting_documents.create(
          document_type: SupportingDocument::SUPPORTING_DOCUMENT,
          file_name: params.original_filename,
          file_type: params.content_type,
          file_size: params.tempfile.size,
          file_path: file_path
        )
      end

      def supported_filetype(params)
        SupportedFileTypes::FURTHER_INFORMATION.include? params.content_type
      end

      def return_success(dict)
        render json: {
          success: dict
        }, status: :ok
      end

      def return_error(exception, dict)
        Sentry.capture_exception(exception)
        render json: {
          error: dict
        }, status: :bad_request
      end
    end
  end
end
