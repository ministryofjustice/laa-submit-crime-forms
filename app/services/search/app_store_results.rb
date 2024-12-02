module Search
  class AppStoreResults
    def initialize(app_store_response)
      @app_store_response = app_store_response.with_indifferent_access
    end

    def rows
      @app_store_response[:raw_data].map { Search::Result.new(ListRow.new(_1)) }
    end

    def none?
      total_results.zero?
    end

    def total_results
      @app_store_response.dig(:metadata, :total_results)
    end
  end
end
