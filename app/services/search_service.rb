class SearchService
  class << self
    def call(base_query, params)
      params[:search_string].split.reduce(with_join(base_query)) do |built_query, token|
        word = token.strip
        if laa_reference_or_ufn?(word)
          built_query.where("core_search_fields @@ to_tsquery('simple', ?)", word)
        else
          built_query.where("searchable_defendants.search_fields @@ to_tsquery('simple', ?)", word)
        end
      end
    end

    private

    def with_join(base_query)
      table_name = base_query.model.table_name
      query = base_query.joins('LEFT JOIN defendants searchable_defendants ' \
                               "ON searchable_defendants.defendable_id = #{table_name}.id")
      query.distinct
    end

    def laa_reference_or_ufn?(word)
      word.downcase.starts_with?('laa-') || %r{\A\d+/\d+\z}.match?(word)
    end
  end
end
