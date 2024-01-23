module Steps
  class FirmDetailsForm < Steps::BaseFormObject
    attr_accessor :firm_office_attributes, :solicitor_attributes

    validates :firm_office, presence: true, nested: true
    validates :solicitor, presence: true, nested: true

    def firm_office
      @firm_office ||= Steps::FirmDetails::FirmOfficeForm.new(firm_office_fields.merge(application:))
    end

    def solicitor
      @solicitor ||= Steps::FirmDetails::SolicitorForm.new(solicitor_fields.merge(application:))
    end

    def choices
      YesNoAnswer.values
    end

    private

    # *_fields methods use attribute hash for values from User,
    # object to lookup existing values
    # default to blank (maybe replace with most recent details in the future)
    def firm_office_fields
      (firm_office_attributes || application.firm_office&.attributes || {})
        .slice(*Steps::FirmDetails::FirmOfficeForm.attribute_names)
    end

    def solicitor_fields
      fields = Steps::FirmDetails::SolicitorForm.attribute_names + ['alternative_contact_details']
      (solicitor_attributes || application.solicitor&.attributes || {})
        .slice(*fields)
    end

    def persist!
      firm_office.save!
      solicitor.save!
    end
  end
end
