class OffencesController < ApplicationController
  skip_before_action :authenticate_provider!

  def index
    respond_to do |format|
      format.json { render json: offences }
    end
  end

  private

  def offences
    MainOffence.all.map(&:as_json)
  end
end
