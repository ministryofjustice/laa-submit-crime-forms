require 'rails_helper'

RSpec.describe Providers::OmniauthCallbacksController, type: :controller do
  let(:office_codes) { %w[BBBBBB CCCCCC AAAAAA] }

  before do
    # Mimic the router behavior of setting the Devise scope through the env.
    request.env['devise.mapping'] = Devise.mappings[:provider]

    request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
      provider: 'entra_id',
      uid: 'test-user',
      info: {
        email: 'provider@example.com',
        office_codes: office_codes,
      }
    )
  end

  describe '#entra_id' do
    context 'can access services' do
      before do
        allow(ActiveOfficeCodeService)
          .to receive(:call)
          .with(office_codes)
          .and_return(office_codes)
      end

      it 'redirects to root path' do
        get :entra_id
        expect(response).to redirect_to(root_path)
      end
    end

    context 'cannot access services' do
      let(:office_codes) { [] }

      before do
        allow(ActiveOfficeCodeService)
          .to receive(:call)
          .with(office_codes)
          .and_return(office_codes)
      end

      it 'redirects to inactive office path' do
        get :entra_id
        expect(response).to redirect_to '/errors/inactive_offices'
      end
    end

    context 'office codes deactivated' do
      before do
        allow(ActiveOfficeCodeService)
          .to receive(:call)
          .with(office_codes)
          .and_return([])
      end

      it 'redirects to inactive offices error page' do
        get :entra_id
        expect(response).to redirect_to '/errors/inactive_offices'
      end
    end

    context 'just one office code and it is deactivated' do
      let(:office_codes) { %w[BBBBBB] }

      before do
        allow(ActiveOfficeCodeService)
          .to receive(:call)
          .with(office_codes)
          .and_return([])
      end

      it 'redirects to inactive offices error page' do
        get :entra_id
        expect(response).to redirect_to '/errors/inactive_offices'
      end
    end
  end

  describe '#after_omniauth_failure_path_for' do
    before do
      request.env['devise.mapping'] = Devise.mappings[:provider]
      request.env['omniauth.error'] = double('error')
    end

    context 'when error is login_required' do
      before do
        allow(controller).to receive(:params).and_return(error: 'login_required')
      end

      context 'when tried_silent_auth is already set' do
        it 'clears the flag and returns unauthorized path' do
          session[:tried_silent_auth] = true

          expect(controller.send(:after_omniauth_failure_path_for)).to eq(unauthorized_errors_path)
          expect(session[:tried_silent_auth]).to be_nil
        end
      end

      context 'when tried_silent_auth is not set' do
        it 'sets the flag and returns retry auth path' do
          expect(controller.send(:after_omniauth_failure_path_for)).to eq(providers_retry_auth_path)
          expect(session[:tried_silent_auth]).to be true
        end
      end
    end

    context 'when error is not login_required or interaction_required' do
      it 'returns unauthorized path' do
        allow(controller).to receive(:params).and_return(error: 'access_denied')

        expect(controller.send(:after_omniauth_failure_path_for)).to eq(unauthorized_errors_path)
      end
    end
  end
end
