class ItemTypeDependantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    item_type = item_type_for(record).pluralize

    record.errors.add(attribute, :blank, item_type:) if value.blank?
    if value.is_a?(String)
      # The value will only be a string when the automatic type conversion in Type::FullyValidatableInteger has failed.
      # This is because the value entered by the user is either:
      # * not a number at all
      # * a non-integer number. In this case, `.to_f.to_s should yield the original value`
      error = value.to_f.to_s == value ? :not_a_whole_number : :not_a_number
      record.errors.add(attribute, error, item_type:)
    end
    record.errors.add(attribute, :greater_than, item_type:) if value.to_d <= 0
  end

  def item_type_for(record)
    record.respond_to?(:item_type) ? record.item_type || 'item' : 'item'
  end
end
