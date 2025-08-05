module PriorAuthority
  class ApplicationsController < ApplicationController
    include Searchable
    include Cloneable

    before_action :set_scope, only: %i[submitted drafts]
    before_action :set_default_table_sort_options
    layout 'prior_authority'

    def index
      @notification_banner = NotificationBanner.active_banner
      model = AppStoreListService.reviewed(current_provider, params, service: :prior_authority)
      @pagy = model.pagy
      @model = model.rows
      @scope = :reviewed
      @empty = PriorAuthorityApplication.for(current_provider).none?
    end

    def show
      render locals: application_locals
    end

    def create
      initialize_application do |paa|
        redirect_to edit_prior_authority_steps_prison_law_path(paa)
      end
    end

    def confirm_delete
      @model = PriorAuthorityApplication.for(current_provider).find(params[:id])
    end

    def destroy
      @model = PriorAuthorityApplication.for(current_provider).find(params[:id])
      @model.destroy
      redirect_to drafts_prior_authority_applications_path, flash: { success: t('.deleted') }
    end

    def drafts
      @pagy, @model = order_and_paginate(&:draft)
      render 'index'
    end

    def submitted
      model = AppStoreListService.submitted(current_provider, params, service: :prior_authority)
      @pagy = model.pagy
      @model = model.rows
      render 'index'
    end

    def offboard
      @model = PriorAuthorityApplication.for(current_provider).find(params[:id])
    end

    def download
      pdf = PdfService.prior_authority(application_locals(skip_links: true), request.url)

      send_data pdf,
                filename: "#{current_application.laa_reference}.pdf",
                type: 'application/pdf'
    end

    def clone
      clone = clone_application
      clone.save

      redirect_to prior_authority_steps_start_page_path(clone.id), flash: { success: t('.cloned') }
    end

    def self.model_class
      PriorAuthorityApplication
    end

    ORDERS = {
      'ufn' => 'ufn ?',
      'client' => 'defendants.first_name ?, defendants.last_name ?',
      'last_updated' => 'updated_at ?',
      'state' => 'state ?',
      'office_code' => 'office_code ?'
    }.freeze

    DIRECTIONS = {
      'descending' => 'DESC',
      'ascending' => 'ASC',
    }.freeze

    private

    def current_application
      @current_application ||= AppStoreDetailService.prior_authority(params[:id], current_provider)
    end

    def initialize_application(attributes = {}, &block)
      attributes[:office_code] = current_provider.office_codes.first unless current_provider.multiple_offices?
      current_provider.prior_authority_applications.create!(attributes).tap(&block)
    end

    def order_and_paginate
      query = yield PriorAuthorityApplication.for(current_provider)
      order_template = ORDERS[@sort_by]
      direction = DIRECTIONS[@sort_direction]
      pagy(query.includes(:defendant).order(order_template.gsub('?', direction)))
    end

    def service_for_search
      :prior_authority
    end

    def set_scope
      @scope = params[:action].to_sym
    end

    def set_default_table_sort_options
      @sort_by = params.fetch(:sort_by, 'last_updated')
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end

    def application_locals(skip_links: false)
      application = AppStoreDetailService.prior_authority(params[:id], current_provider)

      {
        application: application,
        primary_quote_summary: PriorAuthority::PrimaryQuoteSummary.new(application),
        report: CheckAnswers::Report.new(application, verbose: true, skip_links: skip_links),
        allowance_type: { 'granted' => :original,
                          'part_grant' => :dynamic,
                          'rejected' => :na }[application.state]
      }
    end
  end
end
