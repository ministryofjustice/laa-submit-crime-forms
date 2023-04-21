require 'steps/base_form_object'

module Steps
  class FirmDetailsForm < Steps::BaseFormObject
    attr_accessor :firm_office_attributes
    attr_accessor :solicitor_attributes

    def firm_office
      @firm_office ||= FirmOfficeForm.new(firm_office_fields, application: application)
    end

    def solicitor
      @solicitor ||= SolicitorForm.new(solicitor_fields, application: application)
    end

    private

    def firm_office_fields
      # use attribute hash for values from User,
      # object to lookup existing values
      # default to blank (maybe replace with most recent details in the future)
      firm_office_attributes || application.firm_office || {}
    end

    def solicitor_fields
      solicitor_attributes || application.solicitor || {}
    end

    def persist!
      true
    end
  end
end
