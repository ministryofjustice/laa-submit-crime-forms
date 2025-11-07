module Search
  class AppStoreService
    class << self
      def call(service, filters)
        search_params = build_search_params(service, filters.with_indifferent_access)
        response = AppStoreClient.new.search(search_params).deep_symbolize_keys
        Search::AppStoreResults.new(response)
      end

      def build_search_params(service, filters)
        filters.slice(:page, :per_page, :sort_by, :sort_direction, :submitted_from, :submitted_to).merge(
          application_type: service == :nsm ? 'crm7' : 'crm4',
          query: filters[:search_string].presence,
          last_state_change_from: filters[:updated_from],
          last_state_change_to: filters[:updated_to],
          status_with_assignment: build_status_with_assignment(filters),
          account_number: filters[:office_code].presence || filters[:current_provider].office_codes
        )
      end

      def build_status_with_assignment(filters)
        case filters[:state]
        when 'granted'
          %w[granted auto_grant]
        when 'submitted'
          %w[not_assigned in_progress]
        else
          filters[:state].presence
        end
      end
    end
  end
end
