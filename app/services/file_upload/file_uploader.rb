module FileUpload
  class FileUploader
    class PotentialMalwareError < StandardError; end

    def initialize
      @uploader = Rails.env.production? ? AwsFileUploader.new : LocalFileUploader.new
    end

    def upload(file)
      scan_file(file)
      @uploader.save(file)
    end

    def destroy(file_path)
      @uploader.destroy(file_path)
    end

    private

    def scan_file(file)
      result = if Rails.env.production? || ENV.fetch('CLAMBY_ENABLED', nil) == 'true'
        Clamby.safe?(file.tempfile.path)
      else
        true
      end

      raise PotentialMalwareError unless result
    end
  end
end
