class ClaimsController < ApplicationController
  include PaginationHelpers

  def index
    # TODO: delete old claims without a claim type or avoid creating
    # claim before we have a claim type - this breaks the pattern we
    # have used for the forms.
    # debugger
    # filtered_claims = Claim.where(claim_type: ClaimType::SUPPORTED.map(&:to_s)).order('updated_at DESC')
    filtered_claims = Claim.all.order('updated_at DESC')
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
    attributes[:laa_reference] = generate_laa_reference
    Claim.create!(attributes).tap(&block)
  end

  def generate_laa_reference
    loop do
      random_reference = "LAA-#{SecureRandom.alphanumeric(6)}"
      break random_reference unless Claim.exists?(laa_reference: random_reference)
    end
  end
end
