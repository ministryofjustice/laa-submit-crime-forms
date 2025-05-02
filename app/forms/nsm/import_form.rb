module Nsm
  class ImportForm < ::Steps::BaseFormObject
    include PriorAuthority::DocumentUploadable

    attribute :file_upload
    validate :file_upload_provided
    validate :correct_filetype

    def supported_filetype?
      return false if file_upload.blank?

      %w[text/plain application/xml text/xml].include?(Marcel::MimeType.for(file_upload.tempfile))
    end

    def validate_xml_file
      # Check if version element exists
      version_node = xml_file.at_xpath('//version')
      return [I18n.t('nsm.imports.errors.missing_version')] if version_node.nil? || version_node.text.blank?

      # Get version number
      version = version_node.text.to_i
      return [I18n.t('nsm.imports.errors.invalid_version')] if version <= 0

      # Check schema file exists
      schema_path = Rails.root.join("app/services/nsm/importers/xml/v#{version}/crm7_claim.xsd")
      return [I18n.t('nsm.imports.errors.unsupported_version', version:)] unless File.exist?(schema_path)

      # Proceed with schema validation - explicitly return the results
      schema = Nokogiri::XML::Schema.new(schema_path.read)
      schema.validate(xml_file)
    end

    def xml_file
      @xml_file ||= Nokogiri::XML::Document.parse(file_upload.tempfile.read, &:noblanks)
    end

    private

    def file_upload_provided
      return if file_upload.present?

      errors.add(:file_upload, :blank)
    end

    def correct_filetype
      return if supported_filetype?

      errors.add(:file_upload, :forbidden_document_type)
    end
  end
end
