require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:provider]
    request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
      provider: 'entra_id',
      uid: 'test-user',
      info: {
        email: 'provider@example.com',
        office_codes: %w[AAAAAA BBBBBB],
      }
    )
  end

  describe 'GET #index' do
    it 'sets notification banner and renders template' do
      get :index
      expect(assigns(:notification_banner)).to eq(NotificationBanner.active_banner)
      expect(response).to render_template(:index)
    end

    context 'when user is not signed in' do
      it 'does not attempt to destroy session' do
        allow(controller).to receive(:provider_signed_in?).and_return(false)

        get :index, params: { login_hint: 'different@example.com' }

        expect(response).to render_template(:index)
      end
    end

    context 'when user is signed in' do
      let(:mock_provider) { double('provider', email: 'current@example.com') }

      before do
        allow(controller).to receive_messages(provider_signed_in?: true, current_provider: mock_provider)
        allow(controller).to receive(:sign_out)
      end

      it 'does not redirect when login_hint is blank' do
        get :index, params: { login_hint: '' }

        expect(controller).not_to have_received(:sign_out)
        expect(response).to render_template(:index)
      end

      it 'does not redirect when login_hint is invalid email' do
        get :index, params: { login_hint: 'invalid-email' }

        expect(controller).not_to have_received(:sign_out)
        expect(response).to render_template(:index)
      end

      it 'does not redirect when login_hint matches current provider email' do
        get :index, params: { login_hint: 'current@example.com' }

        expect(controller).not_to have_received(:sign_out)
        expect(response).to render_template(:index)
      end

      it 'redirects when login_hint is different from current provider email' do
        get :index, params: { login_hint: 'different@example.com' }

        expect(controller).to have_received(:sign_out).with(mock_provider)
        expect(cookies[:login_hint]).to eq('different@example.com')
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET #dev_login' do
    it 'renders the dev_login template' do
      get :dev_login
      expect(response).to render_template(:dev_login)
    end
  end
end
