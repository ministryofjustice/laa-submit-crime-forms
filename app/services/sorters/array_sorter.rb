module Sorters
  module ArraySorter
    def call(items, sort_by, sort_direction)
      sorted_items = sort_by_field(items, sort_by)
      sorted_items = sorted_items.reverse if sort_direction == 'descending'
      sorted_items
    end

    def sort_by_field(items, sort_by)
      sort_field = self::PRIMARY_SORT_FIELDS.fetch(sort_by)

      items.sort_by do |item|
        if sort_field.respond_to?(:call)
          [sort_field.call(item), item.position]
        else
          [item.send(sort_field), item.position]
        end
      end
    end
  end
end
