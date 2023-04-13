class ProviderOfficesController < ApplicationController
  def index
    render json: ProviderOffice.all
  end

  def show
    @provider_office = ProviderOffice.find(params[:id])
    render json: @provider_office
  end

  def new
    @count = ProviderOffice.count
    @provider_office = ProviderOffice.new(position: @count + 1)
  end

  def create
    @provider_office = ProviderOffice.new(provider_office_params)
    @provider_office.save
  end

  def edit
    @provider_office = ProviderOffice.find(params[:id])
  end

  def update
    @provider_office = ProviderOffice.find(params[:id])
    if @provider_office.update(provider_office_params)
    end
  end

  def delete
    @provider_office = ProviderOffice.find(params[:id])
  end

  def destroy
    @provider_office = ProviderOffice.find(params[:id])
    @provider_office.destroy
  end

  private

  def provider_office_params
    params.permit(
      :guid,
      :account_no,
      :firm_name,
      :address_line1,
      :address_line2,
      :town,
      :post_code,
      :rep_date
    )
  end
end
