require 'rails_helper'

RSpec.describe Providers::OmniauthCallbacksController, type: :controller do
  let(:office_codes) { %w[BBBBBB CCCCCC AAAAAA] }

  let(:office_codes_from_crm4_config) { ['BBBBBB'] }
  let(:office_codes_from_crm5_config) { ['CCCCCC'] }
  let(:office_codes_from_crm7_config) { ['AAAAAA'] }

  before do
    # Mimic the router behavior of setting the Devise scope through the env.
    request.env['devise.mapping'] = Devise.mappings[:provider]

    request.env['omniauth.auth'] = OmniAuth::AuthHash.new({
                                                            provider: 'saml',
      uid: 'test-user',
      info: {
        email: 'provider@example.com',
        roles: 'EFORMS,EFORMS_eFormsAuthor,CRIMEAPPLY',
        office_codes: office_codes
      }
                                                          })

    allow(Rails.configuration.x.gatekeeper.crm4)
      .to receive(:office_codes)
      .and_return(office_codes_from_crm4_config)

    allow(Rails.configuration.x.gatekeeper.crm5)
      .to receive(:office_codes)
      .and_return(office_codes_from_crm5_config)

    allow(Rails.configuration.x.gatekeeper.crm7)
      .to receive(:office_codes)
      .and_return(office_codes_from_crm7_config)
  end

  describe '#saml' do
    context 'can access services' do
      it 'redirects to root path' do
        get :saml
        expect(response).to redirect_to(root_path)
      end
    end

    context 'cannot access services' do
      let(:office_codes) { %w[DDDDD] }

      it 'redirects to root path' do
        get :saml
        expect(response).to redirect_to '/errors/not_enrolled'
      end
    end

    context 'office codes deactivated' do
      before do
        allow(Rails.configuration.x.inactive_offices)
          .to receive(:inactive_office_codes)
          .and_return(%w[BBBBBB CCCCCC AAAAAA])
      end

      it 'redirects to inactive offices error page' do
        get :saml
        expect(response).to redirect_to '/errors/inactive_offices'
      end
    end
  end
end
