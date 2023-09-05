module FileUpload
  class BaseFileUploader
    def save(file)
      perform_save(file)
    end

    def destroy(file_path)
      perform_destroy(file_path)
    end

    protected

    def perform_save(_file)
      raise 'Implement perform_save in sub class'
    end

    def perform_destroy(_file_path)
      raise 'Implement perform_destroy in sub class'
    end

    def generate_file_name
      SecureRandom.uuid.split('-').join
    end
  end
end
