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
            hash = Hash.from_xml(xml_file.to_s)['claim']

            # TODO: CRM457-2473: Refactor this to handle versioning better
            Nsm::Importers::Xml.const_get("v#{xml_file.version.to_i}".capitalize)::Importer.new(claim, hash).call

            redirect_to edit_nsm_steps_claim_type_path(claim.id), flash: { success: build_message(claim) } and return
          else
            errors_file_path.write(@validation_errors.to_json)
            @form_object.errors.add(:file_upload, :validation_errors)
          end
        end
      end
      render :new
    rescue StandardError
      @form_object = ImportForm.new
      @form_object.errors.add(:file_upload, :blank)
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
      schema_file = Rails.root.join("app/services/nsm/importers/xml/v#{xml_file.version.to_i}/crm7_claim.xsd").read
      schema = Nokogiri::XML::Schema.new(schema_file)

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
