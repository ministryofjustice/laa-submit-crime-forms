class SubmissionList
  PAGE_SIZE = AppStoreListService::PAGE_SIZE

  def initialize(search_response, params)
    @search_response = search_response
    @params = params
  end

  def pagy
    if @search_response.dig(:metadata, :total_results)
      Pagy.new(
        count: @search_response.dig(:metadata, :total_results),
        limit: @search_response.dig(:metadata, :per_page),
        page: @params[:page]
      )
    else
      pagy = Pagy::Countless.new(limit: PAGE_SIZE, page: @params[:page])
      pagy.finalize(row_count_for_countless)
    end
  end

  def rows
    raw_rows.first(PAGE_SIZE).map { ListRow.new(_1) }
  end

  private

  def raw_rows
    @search_response[:raw_data]
  end

  def row_count_for_countless
    return PAGE_SIZE + 1 if more_records_available?

    raw_rows.size
  end

  def more_records_available?
    ActiveModel::Type::Boolean.new.cast(@search_response.dig(:metadata, :has_more))
  end
end
