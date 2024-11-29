require 'rails_helper'

RSpec.describe 'Syncs' do
  describe 'POST /app_store_webhook' do
    it 'responds nicely' do
      post '/app_store_webhook'
      expect(response).to have_http_status :ok
    end
  end
end
