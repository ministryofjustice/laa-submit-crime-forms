class ProviderSolicitorsController < ApplicationController
  def index
    render json: ProviderSolicitor.all
  end

  def show
    @solicitor = ProviderSolicitor.find(params[:id])
    render json: @solicitor
  end

  def new
    @count = ProviderSolicitor.count
    @solicitor = ProviderSolicitor.new(position: @count + 1)
  end

  def create
    @solicitor = ProviderSolicitor.new(solicitor_params)
    @solicitor.save
  end

  def edit
    @solicitor = ProviderSolicitor.find(params[:id])
  end

  def update
    @solicitor = ProviderSolicitor.find(params[:id])
    if @solicitor.update(solicitor_params)
    end
  end

  def delete
    @solicitor = ProviderSolicitor.find(params[:id])
  end

  def destroy
    @solicitor = ProviderSolicitor.find(params[:id])
    @solicitor.destroy
  end

  private

  def solicitor_params
    params.permit(
      :guid,
      :provider,
      :number,
      :email,
      :reference_number,
      :first_name,
      :last_name,
      :contact_name,
      :contact_tel
    )
  end
end
