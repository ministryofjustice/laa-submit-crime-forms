module Nsm
  # Currently this service only imports disbursements and work items, as it is the entering of these that is the most time
  # consuming. However, there is more information available in the XML file that could be imported to save providers time.
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
      xml = validate

      return false if @import_form.errors.present?

      xml.xpath('//work_items/work_item').each { process_work_item(_1) }
      xml.xpath('//disbursements/disbursement').each { process_disbursement(_1) }

      build_message
    end

    def validate
      xml = Nokogiri::XML::Document.parse(File.read(@import_form.file_upload.tempfile))
      schema = Nokogiri::XML::Schema.new(Rails.root.join('config/leap_schema.xml').read)

      schema.validate(xml).map do |error|
        @import_form.errors.add(:file_upload, error)
      end

      xml
    end

    def process_node(node)
      node.children.each_with_object({}) do |child, hash|
        next if child.name.to_sym == :text

        hash[child.name.to_sym] = child.text
      end
    end

    def process_work_item(node)
      claim.work_items.create(process_node(node))
    rescue StandardError
      # If this work item fails we don't want to blow up the whole process
    end

    def process_disbursement(node)
      claim.disbursements.create(process_node(node))
    rescue StandardError
      # If this fails we don't want to blow up the whole process
    end

    def build_message
      I18n.t('nsm.imports.message',
             disbursement: I18n.t('nsm.imports.disbursement').pluralize(claim.disbursements.count),
             disbursement_count: claim.disbursements.count,
             work_item: I18n.t('nsm.imports.work_item').pluralize(claim.work_items.count),
             work_item_count: claim.work_items.count)
    end
  end
end
