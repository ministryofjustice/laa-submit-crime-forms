module SortableTableHelper
  def table_header(column, i18n_stem, index, path)
    aria_sort = params[:sort_by] == column ? params[:sort_direction] : 'none'
    next_direction = params[:sort_direction] == 'ascending' ? 'descending' : 'ascending'
    tag.th(scope: 'col', class: 'govuk-table__header', 'aria-sort': aria_sort) do
      reorder_form(path, column, next_direction, i18n_stem, index)
    end
  end

  def reorder_form(path, column, next_direction, i18n_stem, index)
    tag.form(action: path, method: 'get') do
      safe_join([tag.input(type: 'hidden', name: 'sort_by', value: column),
                 tag.input(type: 'hidden', name: 'sort_direction', value: next_direction),
                 tag.button(type: 'submit', 'data-index': index) do
                   I18n.t("#{i18n_stem}.#{column}")
                 end])
    end
  end
end
