class CostItemTypeDependantValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    cost_item_type = cost_item_type_for(record)
    cost_item_type = cost_item_type.pluralize if options[:pluralize]
    cost_type_translated = I18n.t("prior_authority.steps.service_cost.items.#{cost_item_type.to_s}")

    record.errors.add(attribute, :blank, item_type: cost_type_translated) if value.blank?
    record.errors.add(attribute, :not_a_number, item_type: cost_type_translated) if value.is_a?(String)
    record.errors.add(attribute, :greater_than, item_type: cost_type_translated) if value.to_d <= 0
  end

  def cost_item_type_for(record)
    record.respond_to?(:cost_item_type) ? record.cost_item_type || 'item' : 'item'
  end
end
