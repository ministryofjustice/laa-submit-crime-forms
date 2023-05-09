require 'steps/base_form_object'

module Steps
  class FirmDetailsForm < Steps::BaseFormObject
    attr_accessor :firm_office_attributes, :solicitor_attributes

    validates :firm_office, presence: true, nested_form: true
    validates :solicitor, presence: true, nested_form: true

    def errors_nested
      ErrorWrapper.new(self, [:firm_office, :solicitor])
    end

    alias errors_non_nested errors
    alias errors errors_nested

    def firm_office
      @firm_office ||= Steps::FirmDetails::FirmOfficeForm.new(firm_office_fields.merge(application:))
    end

    def solicitor
      @solicitor ||= Steps::FirmDetails::SolicitorForm.new(solicitor_fields.merge(application:))
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
      (solicitor_attributes || application.solicitor&.attributes || {})
        .slice(*Steps::FirmDetails::SolicitorForm.attribute_names)
    end

    def persist!
      firm_office.save!
      solicitor.save!
    end
  end
end
