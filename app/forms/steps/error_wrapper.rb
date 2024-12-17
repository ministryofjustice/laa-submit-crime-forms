module Steps
  # Used with nested objects to allow errors the nested objects to
  # be displayed. This also fixes the field naming so that it
  # aligns with the field error message (without this the links
  # don't work)
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
        messages = form.errors_non_nested.messages.clone
        fields.each { |field| messages.delete(field.to_s) }
        messages.to_a
      end
    end
  end
end
