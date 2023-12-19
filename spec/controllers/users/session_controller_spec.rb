require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    # needed to allow devise to logout
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#logout' do
    context 'Get request' do
      it 'get request redirects to the root path' do
        get :destroy
        expect(response).to redirect_to('/')
      end
    end

    context 'delete request' do
      it 'get request redirects to the root path' do
        delete :destroy
        expect(response).to redirect_to('/')
      end
    end
  end
end
