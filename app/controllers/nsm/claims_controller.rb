module Nsm
  class ClaimsController < ApplicationController
    layout 'nsm'

    before_action :set_scope, only: %i[submitted draft reviewed]
    before_action :set_default_table_sort_options

    def index
      @notification_banner = NotificationBanner.active_banner
      @pagy, @claims = order_and_paginate(Claim.for(current_provider).reviewed.where.not(ufn: nil))
      @scope = :reviewed
      render 'index'
    end

    def create
      initialize_application do |claim|
        redirect_to edit_nsm_steps_claim_type_path(claim.id)
      end
    end

    def reviewed
      @pagy, @claims = order_and_paginate(Claim.for(current_provider).reviewed.where.not(ufn: nil))
      render 'index'
    end

    def submitted
      @pagy, @claims = order_and_paginate(Claim.for(current_provider).submitted_or_resubmitted.where.not(ufn: nil))
      render 'index'
    end

    def draft
      @pagy, @claims = order_and_paginate(Claim.for(current_provider).draft.where.not(ufn: nil))
      render 'index'
    end

    def confirm_delete
      @model = Claim.for(current_provider).find(params[:id])
    end

    def destroy
      @model = Claim.for(current_provider).find(params[:id])
      @model.destroy
      redirect_to draft_nsm_applications_path
    end

    private

    ORDERS = {
      'ufn' => 'ufn ?',
      'defendant' => 'defendants.first_name ?, defendants.last_name ?',
      'last_updated' => 'updated_at ?',
      'laa_reference' => 'laa_reference ?',
      'state' => 'state ?',
      'account' => 'office_code ?'
    }.freeze

    DIRECTIONS = {
      'descending' => 'DESC',
      'ascending' => 'ASC',
    }.freeze

    def order_and_paginate(query)
      order_template = ORDERS[@sort_by]
      direction = DIRECTIONS[@sort_direction]
      pagy(query.includes(:main_defendant).order(order_template.gsub('?', direction)))
    end

    def set_default_table_sort_options
      @sort_by = params.fetch(:sort_by, 'last_updated')
      @sort_direction = params.fetch(:sort_direction, 'descending')
    end

    def set_scope
      @scope = params[:action].to_sym
    end

    def initialize_application(attributes = {}, &block)
      attributes.merge!(
        office_code: (current_provider.office_codes.first unless current_provider.multiple_offices?),
        submitter: current_provider,
        laa_reference: generate_laa_reference
      )
      Claim.create!(attributes).tap(&block)
    end

    def generate_laa_reference
      loop do
        random_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
        break random_reference unless Claim.exists?(laa_reference: random_reference)
      end
    end

    def service
      Providers::Gatekeeper::NSM
    end
  end
end
