module Nsm
  class ClaimsController < ApplicationController
    include Searchable
    include Cloneable

    layout 'nsm'

    before_action :set_scope, only: %i[submitted draft]
    before_action :set_default_table_sort_options
    before_action :set_new_record

    def index
      @notification_banner = NotificationBanner.active_banner
      @scope = :reviewed
      model = AppStoreListService.reviewed(current_provider, params, service: :nsm)
      @pagy = model.pagy
      @claims = model.rows
      @row_headers = row_headers
    end

    def submitted
      model = AppStoreListService.submitted(current_provider, params, service: :nsm)
      @pagy = model.pagy
      @claims = model.rows
      @row_headers = row_headers
      render 'index'
    end

    def draft
      @row_headers = row_headers({ include_laa_ref: false })
      @pagy, @claims = order_and_paginate(&:draft)
      render 'index'
    end

    def confirm_delete
      @model = Claim.for(current_provider).find(params[:id])
    end

    def destroy
      @model = Claim.for(current_provider).find(params[:id])
      @model.destroy
      redirect_to draft_nsm_applications_path, flash: { success: t('.deleted') }
    end

    def clone
      clone = clone_application
      clone.save

      redirect_to nsm_steps_start_page_path(clone.id), flash: { success: t('.cloned') }
    end

    ORDERS = {
      'ufn' => 'ufn ?',
      'defendant' => 'defendants.first_name ?, defendants.last_name ?',
      'last_updated' => 'updated_at ?',
      'state' => 'state ?',
      'account' => 'office_code ?'
    }.freeze

    DIRECTIONS = {
      'descending' => 'DESC',
      'ascending' => 'ASC',
    }.freeze

    private

    def set_new_record
      @new_record = StartPage::NEW_RECORD
    end

    def row_headers(opts = { include_laa_ref: true })
      if opts[:include_laa_ref]
        %w[ufn defendant account last_updated laa_reference
           state]
      else
        %w[ufn defendant account laa_reference state]
      end
    end

    def order_and_paginate
      query = yield Claim.for(current_provider).where.not(ufn: nil)
      order_template = ORDERS[@sort_by]
      direction = DIRECTIONS[@sort_direction]
      pagy(query.includes(:main_defendant).order(order_template.gsub('?', direction)))
    end

    def service_for_search
      :nsm
    end

    def set_default_table_sort_options
      @sort_by = params.fetch(:sort_by, 'last_updated')
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end

    def set_scope
      @scope = params[:action].to_sym
    end
  end
end
