class ItemTypeDependantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    item_type = item_type_for(record).pluralize

    record.errors.add(attribute, :blank, item_type:) if value.blank?
    if value.is_a?(String)
      error = value.to_f.to_s == value ? :not_a_whole_number : :not_a_number
      record.errors.add(attribute, error, item_type:)
    end
    record.errors.add(attribute, :greater_than, item_type:) if value.to_d <= 0
  end

  def item_type_for(record)
    record.respond_to?(:item_type) ? record.item_type || 'item' : 'item'
  end
end
