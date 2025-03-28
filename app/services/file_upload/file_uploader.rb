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

    delegate :destroy, to: :@uploader

    delegate :exists?, to: :@uploader

    def scan_file(file)
      result = if Rails.env.production? || ENV.fetch('CLAMBY_ENABLED', nil) == 'true'
                 Clamby.safe?(file.tempfile.path)
               else
                 true
               end

      raise PotentialMalwareError unless result
    end

    def self.human_readable_nsm_max_file_size
      "#{(ENV['NSM_MAX_UPLOAD_SIZE_BYTES'].to_i / (1024 * 1024.0)).round}MB"
    end

    def self.human_readable_pa_max_file_size
      "#{(ENV['PA_MAX_UPLOAD_SIZE_BYTES'].to_i / (1024 * 1024.0)).round}MB"
    end
  end
end
