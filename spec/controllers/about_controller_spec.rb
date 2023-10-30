require 'rails_helper'

RSpec.describe AboutController do
  describe '#contact' do
    it 'has a 200 response code' do
      get 'contact'
      expect(response).to have_http_status(:ok)
    end
  end
end
