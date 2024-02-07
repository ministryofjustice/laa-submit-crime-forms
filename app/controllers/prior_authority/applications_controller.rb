module PriorAuthority
  class ApplicationsController < ApplicationController
    before_action :authenticate_provider!
    layout 'prior_authority'

    def index
      @empty = current_provider.prior_authority_applications.none?
      @assessed_pagy, @assessed_model = order_and_paginate(current_provider.prior_authority_applications.assessed)
      @draft_pagy, @draft_model = order_and_paginate(current_provider.prior_authority_applications.draft)
      @submitted_pagy, @submitted_model = order_and_paginate(current_provider.prior_authority_applications.submitted)
    end

    def create
      initialize_application do |paa|
        redirect_to edit_prior_authority_steps_prison_law_path(paa)
      end
    end

    def confirm_delete
      @model = current_provider.prior_authority_applications.find(params[:id])
    end

    def destroy
      @model = current_provider.prior_authority_applications.find(params[:id])
      @model.destroy
      redirect_to prior_authority_applications_path(anchor: 'drafts')
    end

    def draft
      @pagy, @model = order_and_paginate(current_provider.prior_authority_applications.draft)
      render layout: nil
    end

    def assessed
      @pagy, @model = order_and_paginate(current_provider.prior_authority_applications.assessed)
      render layout: nil
    end

    def submitted
      @pagy, @model = order_and_paginate(current_provider.prior_authority_applications.submitted)
      render layout: nil
    end

    private

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

    def order_and_paginate(query)
      order_template = ORDERS.fetch(params[:sort_by], 'created_at ?')
      direction = params[:sort_direction] == 'descending' ? 'DESC' : 'ASC'
      pagy(query.includes(:defendant).order(order_template.gsub('?', direction)))
    end
  end
end
