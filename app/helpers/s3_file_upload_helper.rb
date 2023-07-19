# frozen_string_literal: true

module S3FileUploadHelper
  def upload_evidence(key)
    S3_BUCKET.put_object(
      key: key
    )
  rescue StandardError => e
    Sentry.capture_event(e)
  end
end