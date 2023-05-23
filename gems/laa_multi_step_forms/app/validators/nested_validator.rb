class NestedValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return unless value

    was_array = value.is_a?(Array)

    Array(value).each.with_index do |sub_record, index|
      add_indexed_errors(object, attribute, was_array, sub_record, index) unless sub_record.valid?
    end
  end

  private

  def add_indexed_errors(object, attribute, was_array, sub_record, index)
    sub_record.errors.each do |error|
      attr_name = indexed_attribute(index, attribute, was_array, error.attribute)

      object.errors.add(
        attr_name,
        error.type,
        message: error_message(sub_record, error), name: error_message_name(object, index)
      )

      # We define the attribute getter as it doesn't really exist
      object.define_singleton_method(attr_name) do
        sub_record.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(index, attribute, was_array, attr)
    return "#{attribute}-attributes[#{index}].#{attr}" if was_array

    "#{attribute}-attributes.#{attr}"
  end

  # `activemodel.errors.models.steps/case/offence_date_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end

  def error_message_name(object, index)
    if options[:name]
      object.method(options[:name]).call(index)
    else
      index + 1
    end
  end
end
