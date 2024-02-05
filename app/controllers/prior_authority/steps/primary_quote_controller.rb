module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      skip_before_action :verify_authenticity_token, only: [:update]

      def edit
        @form_object = PrimaryQuoteForm.build(
          primary_quote,
          application: current_application
        )

        @primary_quote_document = current_application.primary_quote_document
      end

      def update
        @primary_quote_document = current_application.primary_quote_document
        record = primary_quote
        unless supported_filetype(params[:prior_authority_steps_primary_quote_form][:documents])
          return return_error(nil, { message: 'Incorrect file type provided' })
        end
        evidence = upload_file(params)
        update_and_advance(PrimaryQuoteForm, as:, after_commit_redirect_path:, record:)
      rescue FileUpload::FileUploader::PotentialMalwareError => e
        return_error(e, { message: 'File potentially contains malware so cannot be uploaded. ' \
                                   'Please contact your administrator' })
      rescue StandardError => e
        return_error(e, { message: 'Unable to upload file at this time' })
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
        file_path = file_uploader.upload(params[:prior_authority_steps_primary_quote_form][:documents])
        save_file(params[:prior_authority_steps_primary_quote_form][:documents], file_path)
      end

      def save_file(params, file_path)
        current_application.build_primary_quote_document(
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

      def return_error(exception, dict)
        Rails.logger.debug(exception)
        Sentry.capture_exception(exception)
        flash[:alert] = dict[:message]
        redirect_to edit_prior_authority_steps_primary_quote_path(current_application)
      end
    end
  end
end
