module Nsm
  class ImportsController < ApplicationController
    include ClaimCreatable

    before_action :ensure_params, only: [:create]

    def new
      @form_object = ImportForm.new
      @validation_errors = []
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
      else
        current_provider.failed_imports.create
        render :new
      end
    end

    def errors
      error_id = params.fetch(:error_id)

      raise StandardError if error_id.blank?

      begin
        error_object = FailedImport.find(error_id)
        if error_object&.details.present?
          generate_error_download
        else
          render 'nsm/imports/missing_file'
        end
      rescue StandardError
        render 'nsm/imports/missing_file'
      end
    end

    def self.model_class
      Claim
    end

    private

    def generate_error_download
      page = render_to_string(
        template: 'nsm/imports/errors',
        layout: 'pdf'
      )

      pdf = PdfService.html_to_pdf(page, request.url)
      send_data pdf,
                filename: 'laa_xml_errors.pdf',
                type: 'application/pdf'
    end

    def process_successful_import(claim)
      hash = claim_hash
      version = extract_version_from_xml
      import_claim(claim, hash, version)

      claim.import_date = DateTime.now
      claim.save

      redirect_to edit_nsm_steps_claim_type_path(claim.id), flash: { success: build_message(claim) }
    end

    def import_claim(claim, hash, version)
      Nsm::Importers::Xml.const_get("V#{version}".capitalize)::Importer.new(claim, hash).call
    end

    def handle_validation_errors
      @form_object.errors.add(:file_upload, :validation_errors)
      errors_object = current_provider.failed_imports.create(details: @validation_errors.to_json)
      render :new, locals: { error_id: errors_object.id }
    end

    def ensure_params
      return if params[:nsm_import_form].present? && params[:nsm_import_form][:file_upload].present?

      @form_object = ImportForm.new
      @form_object.errors.add(:file_upload, :blank)
      render :new
    end

    def xml_file
      @xml_file ||= Nokogiri::XML::Document.parse(@form_object.file_upload.tempfile.read, &:noblanks)
    end

    # The version of the schema to compare an export against.
    def extract_version_from_xml
      version_node = xml_file.at_xpath('//version')
      if version_node&.text.present?
        version = version_node.text.to_i
        return version if version.positive?
      end

      raise StandardError, I18n.t('nsm.imports.errors.missing_version')
    end

    # Strip out any attributes on the root claim node
    # by copying the children over to a new node
    def claim_hash
      claim_node = xml_file.at_xpath('//claim')

      new_doc = Nokogiri::XML::Document.new
      new_doc.root = Nokogiri::XML::Node.new('claim', new_doc)

      claim_node.children.each { |child| new_doc.root.add_child(child.dup) }

      # Make sure to remove version from hash here as well
      Hash.from_xml(new_doc.to_s)['claim'].except('version')
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
