module MultiFileUploadable
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token, only: [:create]
  end

  def create
    return return_error('activemodel.errors.messages.forbidden_document_type') unless supported_filetype?(params[:documents])

    evidence = upload_file(params)
    return_success({ evidence_id: evidence.id, file_name: params[:documents].original_filename })
  rescue FileUpload::FileUploader::PotentialMalwareError => e
    return_error('activemodel.errors.messages.suspected_malware', e)
  rescue StandardError => e
    return_error('activemodel.errors.messages.upload_failed', e)
  end

  private

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

  def supported_filetype?(params)
    SupportedFileTypes::SUPPORTED_FILE_TYPES.include?(
      Marcel::MimeType.for(params.tempfile)
    )
  end

  def return_success(dict)
    render json: {
      success: dict
    }, status: :ok
  end

  def return_error(key, exception = nil)
    Sentry.capture_exception(exception) if exception
    render json: {
      error: { message: t(key) }
    }, status: :bad_request
  end
end
