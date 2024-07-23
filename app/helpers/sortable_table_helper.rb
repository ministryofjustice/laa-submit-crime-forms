module SortableTableHelper
  def table_header(column, i18n_stem, index, path, sort_by, sort_direction, additional_classes: [])
    aria_sort, next_direction = sort_variable(column, sort_by, sort_direction)

    next_direction = sort_direction == 'ascending' ? 'descending' : 'ascending'
    tag.th(scope: 'col', class: ['govuk-table__header'] + additional_classes, 'aria-sort': aria_sort) do
      reorder_form(path, column, next_direction, i18n_stem, index)
    end
  end

  def reorder_form(path, column, next_direction, i18n_stem, index)
    tag.form(action: path, method: 'get') do
      safe_join([tag.input(type: 'hidden', name: 'sort_by', value: column),
                 tag.input(type: 'hidden', name: 'sort_direction', value: next_direction),
                 tag.button(type: 'submit', 'data-index': index) do
                   I18n.t(column, scope: i18n_stem)
                 end])
    end
  end

  def sort_variable(column, sort_by, sort_direction)
    if sort_by == column
      [
        sort_direction,
        sort_direction == 'ascending' ? 'descending' : 'ascending'
      ]
    else
      [
        'none',
        'descending'
      ]
    end
  end

end
