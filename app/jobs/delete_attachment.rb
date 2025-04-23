class DeleteAttachment < ApplicationJob
  def perform(file_path)
    return unless file_path.nil? || file_uploader.exists?(file_path)

    Rails.logger.info("Deleting path #{file_path}")
    file_uploader.destroy(file_path)
  end

  private

  def file_uploader
    @file_uploader ||= FileUpload::FileUploader.new
  end
end
