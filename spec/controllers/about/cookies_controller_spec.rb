require 'rails_helper'

RSpec.describe About::CookiesController do
  describe '#cookies' do
    context 'index' do
      context 'analytics disabled' do
        before do
          get :index
        end

        it 'has a 200 response code' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'analytics enabled' do
        before do
          request.cookies['analytics_cookies_set'] = true
          get :index
        end

        it 'has a 200 response code' do
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'create' do
      before do
        post :create, params: cookie_params
      end

      context 'accept analytics' do
        let(:cookie_params) do
          { cookie: { 'analytics' => 'true' } }
        end

        it 'has a 200 response code' do
          expect(response).to redirect_to(about_cookies_path)
        end

        it 'returns the cookie set to true' do
          expect(response.cookies).to include({ 'analytics_cookies_set' => 'true' })
        end

        it 'flashes notice' do
          expect(flash.now[:success]).to match(/You've set your cookie preferences./)
        end
      end

      context 'reject analytics' do
        let(:cookie_params) do
          { cookie: { 'analytics' => 'false' } }
        end

        it 'has a 200 response code' do
          expect(response).to redirect_to(about_cookies_path)
        end

        it 'returns the cookie set to false' do
          expect(response.cookies).to include({ 'analytics_cookies_set' => 'false' })
        end

        it 'flashes notice' do
          expect(flash.now[:success]).to match(/You've set your cookie preferences./)
        end
      end

      context 'bad value' do
        let(:cookie_params) do
          { cookie: { 'analytics' => ';-- select * from users;' } }
        end

        it 'redirect to cookies path' do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
