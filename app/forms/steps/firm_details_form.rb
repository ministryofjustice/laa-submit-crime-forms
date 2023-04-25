require 'steps/base_form_object'

module Steps
  # we still need to the base errors object to ensure we don;t break
  # how error handling and validations work. SimpleDelegator is a nice
  # way of doing this and just overwritting the messages response which
  # is used byt the `govuk_error_summary` method
  class ErrorWrapper < SimpleDelegator
    attr_reader :form, :fields

    # fields is the array nested object to be processed
    # pass in nil in the array to include errors off the
    # base object
    def initialize(form, fields)
      super(form.errors_non_nested)
      @form = form
      @fields = fields
    end

    def messages
      fields.flat_map { |field| full_name_attribute(field) }
    end

    private

    def full_name_attribute(name)
      if name
        form[name].errors.messages.map do |key, value|
          ["#{name}_attributes_#{key}", value]
        end
      else
        messages = form.error.messages.clone
        fields.each { |field| messages.delete(field.to_s) }
        messages
      end
    end
  end

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
      firm_office_attributes || application.firm_office&.attributes || {}
    end

    def solicitor_fields
      solicitor_attributes || application.solicitor&.attributes || {}
    end

    def persist!
      firm_office.persist!
      solicitor.persist!
    end
  end
end
