module Nsm
  class ImportsController < ApplicationController
    include ClaimCreatable

    # Define custom exceptions at the top of the class
    class MissingVersionError < StandardError; end
    class UnsupportedVersionError < StandardError; end

    def new
      @form_object = ImportForm.new
      @validation_errors = []

      # Ensure we don't keep a leftover file
      # Can't use Tempfile here as it expires too quickly
      begin
        errors_file_path.unlink
      rescue StandardError
        nil
      end
    end

    def extract_version
      # Try to find version in the XML
      version_node = xml_file.at_xpath('//version')

      if version_node&.text.present?
        version = version_node.text.strip.to_i
        return version if version.positive?
      end

      # Version is missing or invalid
      raise MissingVersionError, "XML file missing valid version information"
    end

    def create
      @form_object = ImportForm.new(params.require(:nsm_import_form).permit(:file_upload))

      if @form_object.valid?
        initialize_application do |claim|
          @validation_errors = validate

          # Check specifically for unsupported version errors
          if @validation_errors.any? { |error| error.include?("version") }
            raise UnsupportedVersionError, @validation_errors.first
          elsif @validation_errors.empty?
            hash = Hash.from_xml(xml_file.to_s)['claim']

            # Get the version from the hash and remove it so it won't be assigned to the claim
            version = hash.delete('version').to_i

            # Dynamically determine the importer class for this version
            importer_class = "Nsm::Importers::Xml::V#{version}::Importer"

            # Check if the importer class exists
            if Object.const_defined?(importer_class)
              importer_class.constantize.new(claim, hash).call
              redirect_to edit_nsm_steps_claim_type_path(claim.id), flash: { success: build_message(claim) } and return
            else
              raise UnsupportedVersionError, "No importer found for XML version #{version}"
            end
          else
            errors_file_path.write(@validation_errors.to_json)
            @form_object.errors.add(:file_upload, :validation_errors)
          end
        end
      end
      render :new
    rescue MissingVersionError, UnsupportedVersionError => e
      # Handle version-specific errors separately
      @form_object ||= ImportForm.new
      @form_object.errors.add(:file_upload, :invalid_version)

      # Write the error to the file so it's available for the PDF
      errors_file_path.write(JSON.generate([e.message]))
      render :new
    rescue ActionController::ParameterMissing
      @form_object = ImportForm.new
      @form_object.errors.add(:file_upload, :blank)
      render :new
    rescue StandardError => e
      # Log unexpected errors for debugging
      Rails.logger.error("XML import error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      @form_object = ImportForm.new
      @form_object.errors.add(:file_upload, :unexpected_error, message: "An unexpected error occurred")
      render :new
    end

    def errors
      @errors = JSON.parse(errors_file_path.read)

      page = render_to_string(
        template: 'nsm/imports/errors',
        layout: 'pdf',
        locals: { errors: @errors }
      )

      pdf = PdfService.html_to_pdf(page, request.url)
      send_data pdf,
                filename: 'laa_xml_errors.pdf',
                type: 'application/pdf'
    end

    def self.model_class
      Claim
    end

    private

    def errors_file_path
      Rails.root.join('tmp', "xml_errors_#{current_provider.id}")
    end

    def xml_file
      @xml_file ||= Nokogiri::XML::Document.parse(@form_object.file_upload.tempfile.read, &:noblanks)
    end

    def validate
      version = extract_version
      schema_path = Rails.root.join("app/services/nsm/importers/xml/v#{version}/crm7_claim.xsd")

      unless File.exist?(schema_path)
        return [I18n.t('nsm.imports.errors.unsupported_version', version: version)]
      end

      schema = Nokogiri::XML::Schema.new(schema_path.read)
      schema.validate(xml_file)
    end

    def build_message(claim)
      {
        title: I18n.t('nsm.imports.message_title'),
        content: [
          I18n.t('nsm.imports.work_items_message', count: claim.work_items.count),
          I18n.t('nsm.imports.disbursements_message', count: claim.disbursements.count),
          '<br/><br/>',
          I18n.t('nsm.imports.message_end')
        ].join
      }
    end
  end
end
