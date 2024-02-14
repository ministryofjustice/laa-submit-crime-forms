module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      def edit
        @form_object = PrimaryQuoteForm.build(
          primary_quote,
          application: current_application
        )

        @primary_quote_document = current_application.primary_quote.document
      end

      def update
        record = primary_quote
        @primary_quote_document = current_application.primary_quote.document
        pending_document = params[:prior_authority_steps_primary_quote_form][:document]

        return if file_error_present(pending_document)

        upload_file(pending_document) unless pending_document.nil?
        update_and_advance(PrimaryQuoteForm, as:, after_commit_redirect_path:, record:)
      rescue FileUpload::FileUploader::PotentialMalwareError => e
        return_error(t('shared.shared_upload_errors.malware'), e)
      rescue StandardError => e
        return_error(t('shared.shared_upload_errors.unable_upload'), e)
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

      def upload_file(file)
        file_path = file_uploader.upload(file)
        save_file(file, file_path)
      end

      def save_file(params, file_path)
        record = current_application.primary_quote.document || current_application.primary_quote.build_document
        record.document_type = SupportingDocument::QUOTE_DOCUMENT
        record.file_name = params.original_filename
        record.file_type = params.content_type
        record.file_size = params.tempfile.size
        record.file_path = file_path
        record.save!
      end

      def supported_filetype(file)
        SupportedFileTypes::QUOTE_DOCUMENT
          .include? file.content_type
      end

      def file_size_within_limit(file)
        file.tempfile.size <= ENV.fetch(
          'MAX_UPLOAD_SIZE_BYTES', nil
        ).to_i
      end

      def no_document_in_quote
        !current_application.primary_quote.document&.file_name
      end

      def file_error_present(file)
        if file.nil? && no_document_in_quote && !params[:commit_draft]
          return_error(t('shared.shared_upload_errors.file_not_present', file: 'primary quote'))
        elsif file && !file_size_within_limit(file)
          return_error(t('shared.shared_upload_errors.file_size_limit', max_size: '10MB'))
        elsif file && !supported_filetype(file)
          return_error(t('shared.shared_upload_errors.file_type',
                                    file_types: t('shared.shared_upload_errors.file_types')))
        else
          false
        end
      end

      def return_error(message, exception = nil)
        if exception.nil?
          Sentry.capture_exception(message)
        else
          Sentry.capture_exception(exception)
        end
        flash[:alert] = message
        redirect_to edit_prior_authority_steps_primary_quote_path(current_application)
      end
    end
  end
end
