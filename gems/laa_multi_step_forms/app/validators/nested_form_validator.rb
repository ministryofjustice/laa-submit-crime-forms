class NestedFormValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.valid?

    record.errors.add(attribute, :invalid)
  end
end
