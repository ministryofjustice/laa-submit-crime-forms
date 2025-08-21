module Search
  class UfnChecker
    include ActiveModel::Validations

    attr_accessor :ufn

    def initialize(ufn)
      @ufn = ufn
    end

    validates :ufn, ufn: true
  end

  class LocalService
    class << self
      def call(base_query, params)
        prepare(base_query).then { filter_on_search_string(_1, params) }
                           .then { filter_on_state(_1, params) }
                           .then { filter_on_office_code(_1, params) }
                           .then { filter_on_updated_at(_1, params) }
                           .then { filter_on_submission_date(_1, params) }
      end

      private

      def escape_string(string)
        %('''#{string.gsub("'", "''")}''')
      end

      def filter_on_search_string(base_query, params)
        return base_query if params[:search_string].blank?

        params[:search_string].split.reduce(base_query) do |built_query, token|
          word = token.strip

          if ufn?(word)
            built_query.where("ufn @@ to_tsquery('simple', ?)", escape_string(word))
          else
            built_query.where("searchable_defendants.search_fields @@ to_tsquery('simple', ?)", escape_string(word))
          end
        end
      end

      def filter_on_state(base_query, params)
        return base_query if params[:state].blank?

        statuses = params[:state] == 'granted' ? %w[granted auto_grant] : params[:state]

        base_query.where(state: statuses)
      end

      def filter_on_office_code(base_query, params)
        return base_query if params[:office_code].blank?

        base_query.where(office_code: params[:office_code])
      end

      def filter_on_updated_at(base_query, params)
        return base_query if params[:updated_from].blank? && params[:updated_to].blank?

        base_query.where(updated_at: (params[:updated_from]&.beginning_of_day)..(params[:updated_to]&.end_of_day))
      end

      def filter_on_submission_date(base_query, params)
        return base_query if params[:submitted_from].blank? && params[:submitted_to].blank?

        base_query.where(
          originally_submitted_at: (params[:submitted_from]&.beginning_of_day)..(params[:submitted_to]&.end_of_day)
        )
      end

      def prepare(base_query)
        table_name = base_query.model.table_name
        query = base_query.draft.where.not(ufn: nil).joins('LEFT JOIN defendants searchable_defendants ' \
                                                           "ON searchable_defendants.defendable_id = #{table_name}.id")
        query.distinct
      end

      def ufn?(word)
        UfnChecker.new(word).validate
      end
    end
  end
end
