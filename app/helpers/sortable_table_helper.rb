module SortableTableHelper
  def table_header(column, i18n_stem, index, path, sort_by, sort_direction, additional_classes: [])
    table_header_tag(column, sort_by, sort_direction, additional_classes:) do |next_direction|
      reorder_form(path, column, next_direction, i18n_stem, index)
    end
  end

  def table_header_with_link(column, i18n_stem, params, sort_by, sort_direction)
    table_header_tag(column, sort_by, sort_direction) do |next_direction|
      link_to url_for(params.symbolize_keys.merge(sort_by: column, sort_direction: next_direction)) do
        tag.button do
          I18n.t(column, scope: i18n_stem)
        end
      end
    end
  end

  def table_header_tag(column, sort_by, sort_direction, additional_classes: [])
    aria_sort, next_direction = sort_variable(column, sort_by, sort_direction)

    tag.th(scope: 'col', class: ['govuk-table__header'] + additional_classes, 'aria-sort': aria_sort) do
      yield next_direction
    end
  end

  def reorder_form(path, column, next_direction, i18n_stem, index, options = {})
    tag.form(action: path, method: 'get') do
      safe_join([
                  tag.input(type: 'hidden', name: 'prefix', value: params['prefix']),
                  tag.input(type: 'hidden', name: 'sort_by', value: column),
                  tag.input(type: 'hidden', name: 'sort_direction', value: next_direction),
                  tag.button(type: 'submit', 'data-index': index, id: options[:button_id]) do
                    I18n.t(column, scope: i18n_stem)
                  end
                ])
    end
  end

  def sort_variable(column, sort_by, sort_direction)
    if sort_by.to_s == column
      [
        sort_direction,
        sort_direction == 'ascending' ? 'descending' : 'ascending'
      ]
    else
      %w[
        none
        ascending
      ]
    end
  end
end
