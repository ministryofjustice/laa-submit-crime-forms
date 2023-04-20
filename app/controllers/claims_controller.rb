class ClaimsController < ApplicationController
  def index
    @claims = Claim.all
  end

  def create
    initialize_application do |claim|
      redirect_to edit_steps_claim_type_path(claim.id)
    end
  end

  private

  def initialize_application(attributes = {}, &block)
    attributes[:office_code] = current_office_code

    Claim.create!(attributes).tap do |crime_application|
      yield(crime_application)
    end
  end
end
