module PriorAuthority
  class ApplicationsController < ApplicationController
    before_action :set_scope, only: %i[reviewed submitted drafts]
    before_action :set_default_table_sort_options
    layout 'prior_authority'

    def index
      @notification_banner = NotificationBanner.active_banner
      @pagy, @model = order_and_paginate(&:reviewed)
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

    def reviewed
      @pagy, @model = order_and_paginate(&:reviewed)
      render 'index'
    end

    def submitted
      @pagy, @model = order_and_paginate(&:submitted_or_resubmitted)
      render 'index'
    end

    def search
      @form = SearchForm.new(params)
      @pagy, @model = order_and_paginate { SearchService.call(_1, @form.attributes) } if @form.submitted? && @form.valid?
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

    private

    def initialize_application(attributes = {}, &block)
      attributes[:office_code] = current_provider.office_codes.first unless current_provider.multiple_offices?
      current_provider.prior_authority_applications.create!(attributes).tap(&block)
    end

    def service
      Providers::Gatekeeper::PAA
    end

    ORDERS = {
      'ufn' => 'ufn ?',
      'client' => 'defendants.first_name ?, defendants.last_name ?',
      'last_updated' => 'updated_at ?',
      'laa_reference' => 'laa_reference ?',
      'state' => 'state ?',
      'office_code' => 'office_code ?'
    }.freeze

    DIRECTIONS = {
      'descending' => 'DESC',
      'ascending' => 'ASC',
    }.freeze

    def order_and_paginate
      query = yield PriorAuthorityApplication.for(current_provider)
      order_template = ORDERS[@sort_by]
      direction = DIRECTIONS[@sort_direction]
      pagy(query.includes(:defendant).order(order_template.gsub('?', direction)))
    end

    def set_scope
      @scope = params[:action].to_sym
    end

    def set_default_table_sort_options
      @sort_by = params.fetch(:sort_by, 'last_updated')
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end

    def application_locals(skip_links: false)
      application = PriorAuthorityApplication.for(current_provider).find(params[:id])
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
