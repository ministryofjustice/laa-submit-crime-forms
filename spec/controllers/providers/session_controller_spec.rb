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
        expect(response).to redirect_to(root_path)
      end
    end

    context 'delete request' do
      it 'get request redirects to the root path' do
        delete :destroy
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#retry_auth' do
    it 'renders auth_form' do
      get :retry_auth

      expect(response).to render_template(:retry_auth)
    end
  end
end
