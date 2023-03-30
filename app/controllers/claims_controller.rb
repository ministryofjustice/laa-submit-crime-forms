class ClaimsController < ApplicationController
  def index
    render json: Claim.all
  end

  def show
  end

  def new
    @count = Claim.count
    @claim = Claim.new(position: @count + 1)
  end

  def create
    @claim = Claim.new(claim_params)
    if @claim.save
    end

    def edit
    end

    def update
    end

    def delete
      @claim=Claim.find(params[:id])
    end

    def destroy
    end

    private

    def claim_params
      params.require(:claim).permit(
        :full_name,
        :reference,
        :tel_number,
        :email,
        :address_line1,
        :town,
        :post_code)
    end
  end
end
