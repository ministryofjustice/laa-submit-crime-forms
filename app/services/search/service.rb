module Search
  # We need a single, sortable, paginatable search across 2 data stores: the local DB for drafts,
  # the app store for submissions. (We could search the local DB for submissions but that requires
  # us to keep the local DB in sync at all times with changes made to the app store, and we want
  # to move away from doing that.)

  # However, this is impossible to always do totally efficiently, because if there are, e.g.,
  # 3 pages-worth of app store results and 1 page-worth of local results, then depending on
  # the sort order we can't know which results to show on the current page unless we load
  # in all 4 pages and sort them all. Therefore, this class involves a compromise. It works as follows:

  # Query first the local DB and the app store DB. If there are no local results, use the app store
  # results; if there are no app store results, use the local results. If there are both, load
  # all results from both places into memory and sort and paginate them on the fly.

  # This means that:
  # 1. All searches involve both a local DB query and an app store query
  # 2. All searches with both local and app store results involve a second app store query
  # 3. When there are lots of results, particularly when there are lots of app store results,
  #    a lot of information needs to be loaded from the app store and munged in memory.

  # However, we put up with the above on the grounds that provider searches are always filtering
  # by office code, and for the most part provider searches will be quite specific - filtering
  # on status, LAA reference, defendant name or UFN will drastically limit the total number of search
  # results.

  # If this becomes a problem as individual providers' submission history grows and they use
  # very broad searches, we may need to enforce limits such as:
  # * Hard-limiting the number of app store search results we retrieve at once, even if it
  #   makes pagination and sorting behave oddly for very broad queries
  # * Forcing users to filter by status, so that we never have to search both drafts and
  #   results at once
  # * Most drastically, pushing drafts and submissions to some unified search index

  # (Although all of this may be obviated if we eventually decide to store drafts in the app store too)
  class Service
    def self.call(service, filters, query_params)
      new(service, filters, query_params).call
    end

    attr_reader :service, :filters, :query_params

    def initialize(service, filters, query_params)
      @service = service
      @filters = filters
      @query_params = query_params
    end

    def call
      local_unpaginated_results = query_local_drafts_without_pagination
      app_store_response_with_paginated_results = query_app_store_with_pagination

      if local_unpaginated_results.none?
        [pagy(app_store_response_with_paginated_results.total_results), app_store_response_with_paginated_results.rows]
      elsif app_store_response_with_paginated_results.none?
        [pagy(local_unpaginated_results.count), paginate_local_results(local_unpaginated_results)]
      else
        combine_and_repaginate(local_unpaginated_results, app_store_response_with_paginated_results.total_results)
      end
    end

    def pagy(total_results)
      Pagy.new(
        count: total_results,
        limit: pagination_params[:per_page],
        page: pagination_params[:page]
      )
    end

    def query_local_drafts_without_pagination
      Search::LocalService.call(base_query, filters)
    end

    def base_query
      case service
      when :nsm
        Claim.for(filters[:current_provider]).includes(:defendants)
      when :prior_authority
        PriorAuthorityApplication.for(filters[:current_provider]).includes(:defendant)
      else
        raise "Unknown service #{service}"
      end
    end

    def query_app_store_with_pagination
      Search::AppStoreService.call(service, filters.merge(pagination_params))
    end

    def combine_and_repaginate(local_unpaginated_results, total_app_store_results)
      app_store_unpaginated_results = Search::AppStoreService.call(service,
                                                                   filters.merge(page: 1, per_page: total_app_store_results))
      combined_results = app_store_unpaginated_results.rows + local_unpaginated_results.map { Search::Result.new(_1) }

      [pagy(combined_results.count), order(combined_results).then { paginate(_1) }]
    end

    def paginate_local_results(local_unpaginated_results)
      local_unpaginated_results.order(local_order)
                               .offset(offset)
                               .limit(pagination_params[:per_page])
                               .map { Search::Result.new(_1) }
    end

    def order(combined_results)
      sorted = combined_results.sort_by do |result|
        raw = result.public_send(unified_sort_by)
        raw.try(:downcase) || raw
      end

      pagination_params[:sort_direction] == 'descending' ? sorted.reverse : sorted
    end

    def paginate(combined_results)
      combined_results[offset..(offset + pagination_params[:per_page])]
    end

    def offset
      @offset ||= (pagination_params[:page] - 1) * pagination_params[:per_page]
    end

    def pagination_params
      {
        page: query_params.fetch(:page, '1').to_i,
        per_page: 10,
        sort_by: unified_sort_by,
        sort_direction: query_params.fetch(:sort_direction, 'descending')
      }
    end

    # Claims and PAAs will sometimes pass in different query params for the same name,
    # and so for simplicity we translate the app store's preferred names for these
    # as our standard
    def unified_sort_by
      case query_params[:sort_by]
      when 'defendant', 'client'
        'client_name'
      when 'account', 'office_code'
        'account_number'
      when 'last_updated'
        'last_state_change'
      when 'state'
        'status_with_assignment'
      else
        query_params.fetch(:sort_by, 'last_state_change')
      end
    end

    def local_order
      order_template = LOCAL_ORDER_TEMPLATES[pagination_params[:sort_by]]
      direction = DIRECTIONS[pagination_params[:sort_direction]]
      order_template.gsub('?', direction)
    end

    LOCAL_ORDER_TEMPLATES = {
      'ufn' => 'ufn ?',
      'client_name' => 'defendants.first_name ?, defendants.last_name ?',
      'last_state_change' => 'updated_at ?',
      'status_with_assignment' => 'state ?',
      'account_number' => 'office_code ?',
    }.freeze

    DIRECTIONS = {
      'descending' => 'DESC',
      'ascending' => 'ASC',
    }.freeze
  end
end
