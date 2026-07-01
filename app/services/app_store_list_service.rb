module AppStoreListService
  PAGE_SIZE = 10

  class << self
    def submitted(provider, params, service:)
      perform_search(%i[in_progress not_assigned provider_updated], provider, params, service:)
    end

    def reviewed(provider, params, service:)
      perform_search(%i[granted part_grant rejected auto_grant sent_back expired], provider, params, service:)
    end

    def perform_search(statuses, provider, params, service:)
      pagination_params = params.permit(:page, :sort_direction).to_h.symbolize_keys
      payload = {
        sort_by: translate_sort_by(params),
        per_page: PAGE_SIZE,
        include_total_results: false,
        application_type: service == :nsm ? 'crm7' : 'crm4',
        account_number: provider.office_codes,
        status_with_assignment: statuses
      }.merge(pagination_params)

      search_response = AppStoreClient.new.search(payload)
      SubmissionList.new(search_response.with_indifferent_access, params)
    end

    def translate_sort_by(params)
      case params[:sort_by]
      when 'defendant', 'client'
        'client_name'
      when 'account', 'office_code'
        'account_number'
      when 'last_updated'
        'last_state_change'
      when 'state'
        'status_with_assignment'
      else
        params[:sort_by]
      end
    end
  end
end
