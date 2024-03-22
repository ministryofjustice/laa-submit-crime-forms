module PriorAuthority
  class ApplicationsController < ApplicationController
    before_action :set_default_table_sort_options
    before_action :load_drafts, only: %i[index draft]
    before_action :load_reviewed, only: %i[index reviewed]
    before_action :load_submitted, only: %i[index submitted]
    layout 'prior_authority'

    def index
      @empty = PriorAuthorityApplication.for(current_provider).none?
    end

    def show
      @application = PriorAuthorityApplication.for(current_provider).find(params[:id])
      @primary_quote_summary = PriorAuthority::PrimaryQuoteSummary.new(@application)
      @report = CheckAnswers::Report.new(@application, verbose: true)
      @allowance_type = { 'granted' => :original,
                          'part_grant' => :dynamic,
                          'rejected' => :na }[@application.status]
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
      redirect_to prior_authority_applications_path(anchor: 'drafts')
    end

    def draft
      render layout: nil
    end

    def reviewed
      render layout: nil
    end

    def submitted
      render layout: nil
    end

    def offboard
      @model = PriorAuthorityApplication.for(current_provider).find(params[:id])
    end

    private

    def load_drafts
      @draft_pagy, @draft_model = order_and_paginate(PriorAuthorityApplication.for(current_provider).draft)
    end

    def load_reviewed
      @reviewed_pagy, @reviewed_model = order_and_paginate(PriorAuthorityApplication.for(current_provider).reviewed)
    end

    def load_submitted
      @submitted_pagy, @submitted_model = order_and_paginate(PriorAuthorityApplication.for(current_provider).submitted)
    end

    def initialize_application(attributes = {}, &block)
      attributes[:office_code] = current_office_code
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
      'status' => 'status ?'
    }.freeze

    DIRECTIONS = {
      'descending' => 'DESC',
      'ascending' => 'ASC',
    }.freeze

    def order_and_paginate(query)
      order_template = ORDERS[@sort_by]
      direction = DIRECTIONS[@sort_direction]
      pagy(query.includes(:defendant).order(order_template.gsub('?', direction)))
    end

    def set_default_table_sort_options
      @sort_by = params.fetch(:sort_by, 'last_updated')
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end
  end
end
