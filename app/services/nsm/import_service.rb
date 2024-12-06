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
      xml = Nokogiri::XML(File.read(@import_form.file_upload.tempfile))
      xml.xpath('//fielddata/Schedule/row').each { process_work_item(_1) }
      xml.xpath('//fielddata/Db/row').each { process_disbursement(_1) }

      if claim.work_items.none? && claim.disbursements.none?
        @import_form.errors.add(:file_upload, :no_imports)
        return false
      end

      build_message
    end

    def process_work_item(node)
      claim.work_items.create(
        work_type: work_type(node),
        time_spent: time_spent(node),
        completed_on: node.css('Date').text,
        fee_earner: node.css('Fe_initials').text,
        uplift: node.css('Uplift').text,
        position: node.css('Line').text
      )
    rescue StandardError
      # If this work item fails we don't want to blow up the whole process
    end

    def time_spent(node)
      # Sometimes there are times for every work type, plus a total, sometimes there is just one time
      time_string = (node.css('Time_total').presence || node.children.find { _1.name.starts_with?('Time_') }).text
      hours, minutes, = time_string.split(':').map(&:to_i)

      (hours * 60) + minutes
    end

    def work_type(node)
      {
        'Travel' => 'travel',
        'Waiting' => 'waiting',
        'Preparation' => 'preparation',
        'Advocacy' => 'advocacy',
        'Attendance With Counsel Assigned' => 'attendance_with_counsel',
        'Attendance Without Counsel Assigned' => 'attendance_without_counsel',
      }[node.css('Cost_type').text]
    end

    def process_disbursement(node)
      claim.disbursements.create(
        disbursement_type: disbursement_type(node),
        other_type: other_type(node),
        miles: node.css('Mileage').text,
        total_cost_without_vat: node.css('Net').text,
        details: node.css('Details').text,
        apply_vat: apply_vat(node),
        vat_amount: node.css('Vat').text,
      )
    rescue StandardError
      # If this work item fails we don't want to blow up the whole process
    end

    def disbursement_type(node)
      {
        'Car Travel' => 'car',
        'Motorcycle Travel' => 'motorcycle',
        'Bike Travel' => 'bike',
      }.fetch(node.css('Disbursement').text, 'other')
    end

    def other_type(node)
      return unless disbursement_type(node) == 'other'

      node.css('Disbursement').text
    end

    def apply_vat(node)
      node.css('Vat').text.to_i.positive? ? 'true' : 'false'
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
