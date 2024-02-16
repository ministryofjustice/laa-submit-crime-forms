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

    def scan_file(file)
      result = if Rails.env.production? || ENV.fetch('CLAMBY_ENABLED', nil) == 'true'
                 Clamby.safe?(file.tempfile.path)
               else
                 true
               end

      raise PotentialMalwareError unless result
    end

    def self.human_readable_max_file_size
      "#{(ENV['MAX_UPLOAD_SIZE_BYTES'].to_i / (1024 * 1024.0)).round}MB"
    end
  end
end
