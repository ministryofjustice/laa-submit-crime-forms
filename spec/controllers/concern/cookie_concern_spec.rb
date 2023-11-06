# frozen_string_literal: true

RSpec.describe About::CookiesController, type: :request do
  context 'update_cookies' do
    context 'update analytics' do
      context 'accept' do
        before do
          get '/about/update_cookies', params: { cookies_preference: true }
        end

        it 'should render success partial' do
          expect(response).to render_template(:partial => 'layouts/cookie_banner/_success')
        end

        it 'should render success partial' do
          expect(response.body).to match(/You’ve accepted additional cookies./)
        end
      end

      context 'reject' do
        before do
          get '/about/update_cookies', params: { cookies_preference: false }
        end

        it 'should render success partial' do
          expect(response).to render_template(:partial => 'layouts/cookie_banner/_success')
        end

        it 'should render success partial' do
          expect(response.body).to match(/You’ve rejected additional cookies./)
        end
      end
    end

    context 'hide banner' do
      before do
        get '/about/update_cookies', params: { hide_banner: true }
      end

      it 'should render success partial' do
        expect(response).to render_template(:partial => 'layouts/cookie_banner/_hide')
      end
    end
  end
end
