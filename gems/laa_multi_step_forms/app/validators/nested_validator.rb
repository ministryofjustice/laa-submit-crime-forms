class NestedValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.each.with_index do |sub_record, index|
      add_indexed_errors(record, attribute, sub_record, index) unless sub_record.valid?
    end
  end

  private

  def add_indexed_errors(record, attribute, sub_record, index)
    sub_record.errors.each do |error|
      attr_name = indexed_attribute(index, attribute, error.attribute)

      record.errors.add(
        attr_name,
        error.type,
        message: error_message(sub_record, error), name: error_message_name(record, index)
      )

      # We define the attribute getter as it doesn't really exist
      record.define_singleton_method(attr_name) do
        sub_record.public_send(error.attribute)
      end
    end
  end

  def indexed_attribute(index, attribute, attr)
    "#{attribute}-attributes[#{index}].#{attr}"
  end

  # `activemodel.errors.models.steps/case/offence_date_fieldset_form.summary.x.y`
  def error_message(obj, error)
    I18n.t(
      "#{obj.model_name.i18n_key}.summary.#{error.attribute}.#{error.type}",
      scope: [:activemodel, :errors, :models]
    )
  end

  def error_message_name(record, index)
    if options[:name]
      record.method(options[:name]).call(index)
    else
      index + 1
    end
  end
end
