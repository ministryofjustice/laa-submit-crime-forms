class ClaimsController < ApplicationController
  include PaginationHelpers
  
  def index
    # TODO: delete old claims without a claim type or avoid creating
    # claim before we have a claim type - this breaks the pattern we
    # have used for the forms.
    filtered_claims = Claim.where(claim_type: ClaimType::SUPPORTED.map(&:to_s))
    @claims = filtered_claims.page(current_page).per(page_size)
  end

  def create
    initialize_application do |claim|
      redirect_to edit_steps_claim_type_path(claim.id)
    end
  end

  private

  def initialize_application(attributes = {}, &block)
    attributes[:office_code] = current_office_code

    Claim.create!(attributes).tap(&block)
  end
end
