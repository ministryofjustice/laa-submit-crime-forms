module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      skip_before_action :verify_authenticity_token, only: [:update]

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
        if params[:prior_authority_steps_primary_quote_form][:document]
          return if file_error_present

          upload_file(params)

        end
        update_and_advance(PrimaryQuoteForm, as:, after_commit_redirect_path:, record:)
      rescue FileUpload::FileUploader::PotentialMalwareError => e
        return_error({ message: t('shared.shared_upload_errors.malware') }, e)
      rescue StandardError => e
        return_error({ message: t('shared.shared_upload_errors.unable_upload') }, e)
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
        file_path = file_uploader.upload(params[:prior_authority_steps_primary_quote_form][:document])
        save_file(params[:prior_authority_steps_primary_quote_form][:document], file_path)
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

      def supported_filetype
        SupportedFileTypes::QUOTE_DOCUMENT
          .include? params[:prior_authority_steps_primary_quote_form][:document].content_type
      end

      def file_size_within_limit
        params[:prior_authority_steps_primary_quote_form][:document].tempfile.size <= ENV.fetch(
          'MAX_UPLOAD_SIZE_BYTES', nil
        ).to_i
      end

      def file_error_present
        if !supported_filetype
          return_error({ message: t('shared.shared_upload_errors.file_type') })
        elsif !file_size_within_limit
          return_error({ message: t('shared.shared_upload_errors.file_size_limit', max_size: '10MB') })
        else
          false
        end
      end

      def return_error(dict, exception = nil)
        if exception.nil?
          Sentry.capture_exception(dict[:message])
        else
          Sentry.capture_exception(exception)
        end
        flash[:alert] = dict[:message]
        update_and_advance(PrimaryQuoteForm, as:, save_and_refresh:, record:)
      end
    end
  end
end
