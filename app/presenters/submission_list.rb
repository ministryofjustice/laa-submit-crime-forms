class SubmissionList
  def initialize(search_response, params)
    @search_response = search_response
    @params = params
  end

  def pagy
    Pagy.new(count: @search_response.dig(:metadata, :total_results),
             limit: @params[:per_page],
             page: @params[:page])
  end

  def rows
    @search_response[:raw_data].map { ListRow.new(_1) }
  end
end
