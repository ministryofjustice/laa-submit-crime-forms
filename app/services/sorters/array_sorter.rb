module Sorters
  module ArraySorter
    def call(items, sort_by, sort_direction)
      sorted_items = sort_by_field(items, sort_by)
      sorted_items = sorted_items.reverse if sort_direction == 'descending'
      sorted_items
    end

    def sort_by_field(items, sort_by_key)
      sort_field = self::PRIMARY_SORT_FIELDS.fetch(sort_by_key)[:sort_by]
      sort_type_nil = sort_type_for_nil(sort_by_key)

      items.sort_by do |item|
        if sort_field.respond_to?(:call)
          [sort_field.call(item) || sort_type_nil, item.position]
        else
          [item.send(sort_field) || sort_type_nil, item.position]
        end
      end
    end

    def sort_type_for_nil(sort_by_key)
      sort_type = self::PRIMARY_SORT_FIELDS.fetch(sort_by_key)[:sort_type]

      case sort_type
      when :string then ''
      when :date then 100.years.ago
      when :number then 0
      end
    end
  end
end
