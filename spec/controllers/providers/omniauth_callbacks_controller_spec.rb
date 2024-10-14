require 'rails_helper'

RSpec.describe Providers::OmniauthCallbacksController, type: :controller do
  let(:office_codes) { %w[BBBBBB CCCCCC AAAAAA] }

  before do
    # Mimic the router behavior of setting the Devise scope through the env.
    request.env['devise.mapping'] = Devise.mappings[:provider]

    request.env['omniauth.auth'] = OmniAuth::AuthHash.new(
      provider: 'saml',
      uid: 'test-user',
      info: {
        email: 'provider@example.com',
        roles: 'EFORMS,EFORMS_eFormsAuthor,CRIMEAPPLY',
        office_codes: office_codes,
      }
    )
  end

  describe '#saml' do
    context 'can access services' do
      before do
        allow(ActiveOfficeCodeService)
          .to receive(:call)
          .with(office_codes)
          .and_return(office_codes)
      end

      it 'redirects to root path' do
        get :saml
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
        get :saml
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
        get :saml
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
        get :saml
        expect(response).to redirect_to '/errors/inactive_offices'
      end
    end

    context 'when not in test mode' do
      before do
        allow(FeatureFlags).to receive(:omniauth_test_mode).and_return(double(:omniauth_test_mode, enabled?: false))
        allow(OfficeCodeService).to receive(:call).with('test-user').and_return(%w[DDDDDD EEEEEE])
        allow(ActiveOfficeCodeService).to receive(:call).with(%w[DDDDDD EEEEEE]).and_return(['EEEEEE'])
        get :saml
      end

      it 'redirects to root path' do
        expect(response).to redirect_to(root_path)
      end

      it 'sets the office codes' do
        expect(Provider.find_by(email: 'provider@example.com').office_codes).to eq %w[DDDDDD EEEEEE]
      end
    end
  end
end
