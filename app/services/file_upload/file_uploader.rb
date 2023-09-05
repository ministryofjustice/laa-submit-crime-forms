module FileUpload
  class FileUploader
    def initialize
      @uploader = Rails.env.production? ? AwsFileUploader.new : LocalFileUploader.new
    end

    def upload(file)
      @uploader.save(file)
    end

    def destroy(file_path)
      @uploader.destroy(file_path)
    end
  end
end
