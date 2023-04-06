class ClaimsController < ApplicationController
  def index
    render json: Claim.all
  end

  def show
    @claim = Claim.find(params[:id])
    render json: @claim
  end

  def new
    @count = Claim.count
    @claim = Claim.new(position: @count + 1)
  end

  def create
    @claim = Claim.new(claim_params)
    @claim.save
  end

  def edit
    @claim = Claim.find(params[:id])
  end

  def update
    @claim = Claim.find(params[:id])
    if @claim.update(claim_params)
    end
  end

  def delete
    @task = Claim.find(params[:id])
  end

  def destroy
    @task = Claim.find(params[:id])
    @task.destroy
  end

  private

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
