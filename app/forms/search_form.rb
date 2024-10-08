class SearchForm
  include ActiveModel::Model

  def initialize(params)
    @params = params.fetch(:search_form, {})
  end

  def search_string
    @params[:search_string]
  end

  def submitted?
    @params.key?(:search_string)
  end

  def valid?
    @params[:search_string].present?
  end

  def attributes
    @params.permit(:search_string).to_h
  end
end
