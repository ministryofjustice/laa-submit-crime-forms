module Nsm
  class ImportsController < ApplicationController
    include ClaimCreatable

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

    def create
      @form_object = ImportForm.new(params.expect(nsm_import_form: [:file_upload]))

      if @form_object.valid?
        initialize_application do |claim|
          @validation_errors = validate
          if @validation_errors.empty?
            process_successful_import(claim)
            return # Exit the action after redirect
          else
            handle_validation_errors
          end
        end
      end

      render :new
    rescue ActionController::ParameterMissing
      handle_missing_parameter
    rescue StandardError => e
      handle_standard_error(e)
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

    def handle_missing_parameter
      @form_object = ImportForm.new
      @form_object.errors.add(:file_upload, :blank)
      render :new
    end

    def handle_standard_error(error)
      @form_object = ImportForm.new
      @form_object.errors.add(:file_upload, :unexpected_error, message: error.message)
      render :new
    end

    def process_successful_import(claim)
      hash = prepare_claim_hash
      version = extract_version_from_xml

      import_claim(claim, hash, version)

      redirect_to edit_nsm_steps_claim_type_path(claim.id), flash: { success: build_message(claim) }
    end

    def prepare_claim_hash
      Hash.from_xml(xml_file.to_s)['claim'].except('version')
      hash
    end

    def import_claim(claim, hash, version)
      Nsm::Importers::Xml.const_get("V#{version}".capitalize)::Importer.new(claim, hash).call
    end

    def handle_validation_errors
      errors_file_path.write(@validation_errors.to_json)
      @form_object.errors.add(:file_upload, :validation_errors)
    end

    def errors_file_path
      Rails.root.join('tmp', "xml_errors_#{current_provider.id}")
    end

    def xml_file
      @xml_file ||= Nokogiri::XML::Document.parse(@form_object.file_upload.tempfile.read, &:noblanks)
    end

    # Extract version from XML
    def extract_version_from_xml
      version_node = xml_file.at_xpath('//version')
      if version_node&.text.present?
        version = version_node.text.to_i
        return version if version.positive?
      end

      raise StandardError, I18n.t('nsm.imports.errors.missing_version')
    end

    def validate
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
