module Nsm
  # Currently this service only imports disbursements and work items, as it is the entering of these that is the most time
  # consuming. However, there is more information available in the XML file that could be imported to save providers time.
  module Importers
    module Xml
      class ImportService
        def self.call(claim, import_form)
          new(claim, import_form).call
        end

        attr_reader :claim, :import_form

        def initialize(claim, import_form)
          @claim = claim
          @import_form = import_form
        end

        def call
          validate
          return false if @import_form.errors.present?

          import_xml
          build_message
        end

        def validate
          schema.validate(xml).map do |error|
            @import_form.errors.add(SecureRandom.uuid, error)
          end
        end

        def import_xml
          Nsm::Importers::Xml.const_get(xml_version.capitalize)::Importer.new(@claim, xml_hash).call
        end

        def build_message
          {
            'title' => I18n.t('nsm.imports.message_title'),
            'content' => message_content
          }
        end

        def message_content
          "#{I18n.t('nsm.imports.work_items_message', count: @claim.work_items.count)}
            #{I18n.t('nsm.imports.disbursements_message', count: @claim.disbursements.count)}
            <br><br>#{I18n.t('nsm.imports.message_end')}"
        end

        def schema
          xsd = "app/services/nsm/importers/xml/#{xml_version}/crm7_claim.xsd"
          @schema ||= Nokogiri::XML::Schema.new(Rails.root.join(xsd).read)
        end

        def xml
          @xml ||= Nokogiri::XML::Document.parse(File.read(@import_form.file_upload.tempfile), &:noblanks)
        end

        def xml_hash
          @xml_hash ||= Hash.from_xml(xml.to_s)['claim']
        end

        def xml_version
          "v#{xml.version.to_i}"
        end
      end
    end
  end
end
