class CostItemTypeDependantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    cost_item_type = cost_item_type_for(record)
    cost_item_type = cost_item_type.pluralize if options[:pluralize]
    formatted_cost_item_type = cost_item_type.humanize.downcase

    record.errors.add(attribute, :blank, item_type: formatted_cost_item_type) if value.blank?
    record.errors.add(attribute, :not_a_number, item_type: formatted_cost_item_type) if value.is_a?(String)
    record.errors.add(attribute, :greater_than, item_type: formatted_cost_item_type) if value.to_d <= 0
  end

  def cost_item_type_for(record)
    record.respond_to?(:cost_item_type) ? record.cost_item_type || 'item' : 'item'
  end
end
