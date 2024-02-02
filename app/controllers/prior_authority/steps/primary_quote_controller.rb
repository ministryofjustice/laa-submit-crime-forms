module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      def edit
        @form_object = PrimaryQuoteForm.build(
          primary_quote,
          application: current_application
        )

        @primary_quote_document = current_application.primary_quote_document
      end

      def create
        unless supported_filetype(params[:documents])
          return return_error(nil, { message: 'Incorrect file type provided' })
        end

        evidence = upload_file(params)
        return_success({ evidence_id: evidence.id, file_name: params[:documents].original_filename })
      rescue FileUpload::FileUploader::PotentialMalwareError => e
        return_error(e, { message: 'File potentially contains malware so cannot be uploaded. ' \
                                   'Please contact your administrator' })
      rescue StandardError => e
        return_error(e, { message: 'Unable to upload file at this time' })
      end

      def update
        @primary_quote_document = current_application.primary_quote_document
        record = primary_quote
        update_and_advance(PrimaryQuoteForm, as:, after_commit_redirect_path:, record:)
      end

      private

      def primary_quote
        record = current_application.primary_quote || current_application.build_primary_quote
        record.service_type = record.custom_service_name if record.service_type == 'custom'
        record
      end

      def as
        :primary_quote
      end

      def additional_permitted_params
        [:service_type_suggestion]
      end

      def file_uploader
        @file_uploader ||= FileUpload::FileUploader.new
      end

      def upload_file(params)
        file_path = file_uploader.upload(params[:documents])
        save_file(params[:documents], file_path)
      end

      def save_file(params, file_path)
        current_application.primary_quote_document.create(
          document_type: SupportingDocument::PRIMARY_QUOTE_DOCUMENT,
          file_name: params.original_filename,
          file_type: params.content_type,
          file_size: params.tempfile.size,
          file_path: file_path
        )
      end

      def supported_filetype(params)
        SupportedFileTypes::PRIMARY_QUOTE_DOCUMENT.include? params.content_type
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
