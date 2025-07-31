require 'rails_helper'

RSpec.describe Providers::SessionsController, type: :controller do
  before do
    # needed to allow devise to logout
    request.env['devise.mapping'] = Devise.mappings[:provider]
  end

  describe '#logout' do
    context 'Get request' do
      it 'get request redirects to the root path' do
        get :destroy
        expect(response).to redirect_to(unauthorized_errors_path)
      end
    end

    context 'delete request' do
      it 'get request redirects to the root path' do
        delete :destroy
        expect(response).to redirect_to(unauthorized_errors_path)
      end
    end
  end

  describe '#silent_auth' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:provider]
      Rails.application.routes.draw do
        devise_scope :provider do
          get 'silent_auth', to: 'providers/sessions#silent_auth'
        end
      end
    end

    after do
      Rails.application.reload_routes!
    end

    it 'sets instance variables and renders auth_form' do
      cookies[:login_hint] = 'test@example.com'
      get :silent_auth

      expect(assigns(:login_hint)).to eq('test@example.com')
      expect(assigns(:prompt)).to be_nil
      expect(response).to render_template(:auth_form)
    end
  end

  describe '#retry_auth' do
    it 'sets instance variables and renders auth_form' do
      get :retry_auth

      expect(assigns(:login_hint)).to be_nil
      expect(assigns(:prompt)).to eq('select_account')
      expect(response).to render_template(:auth_form)
    end
  end
end
