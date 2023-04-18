class ClaimsController < ApplicationController
  def index
    render :index, locals: { claims: Claim.all }
  end

  def show
    @claim = Claim.find(params[:id])
    render json: @claim
  end

  def edit
    @claim = Claim.find(params[:id])
  end

  def create
    initialize_application do |claim|
      redirect_to edit_steps_claim_type_path(claim.usn)
    end
  end

  def update
    @claim = Claim.find(params[:id])
  end

  def delete
    @task = Claim.find(params[:id])
  end

  def destroy
    @task = Claim.find(params[:id])
    @task.destroy
  end

  private

  def initialize_application(attributes = {}, &block)
    attributes[:office_code] = current_office_code
    attributes[:usn] = "#{Date.today.to_fs(:number)}-#{SecureRandom.hex(4)}"

    Claim.create(attributes).tap do |crime_application|
      yield(crime_application) if block
    end
  end


  def claim_params
    params.permit(
      :full_name,
      :reference,
      :tel_number,
      :email,
      :address_line1,
      :town,
      :post_code
    )
  end
end
