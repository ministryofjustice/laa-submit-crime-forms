module FileUpload
  class AwsFileUploader < BaseFileUploader
    protected

    def perform_save(file)
      file_name = generate_file_name
      object = S3_BUCKET.object file_name
      object.put(body: file.to_io)

      file_name
    end

    def perform_destroy(file_path)
      remove_request = S3_BUCKET.object file_path
      remove_request.delete
    end

    def perform_exists?(file_path)
      S3_BUCKET.object(file_path).exists?
    end
  end
end
