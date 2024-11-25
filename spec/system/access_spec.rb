require 'rails_helper'

RSpec.describe 'System Access', :stub_app_store_search, :stub_oauth_token, type: :system do
  before do
    allow(ActiveOfficeCodeService).to receive(:call).with(provider.office_codes).and_return(allowed_office_codes)
    visit provider_saml_omniauth_callback_path(
      info: { name: 'Test User', email: 'provider@example.com', office_codes: provider.office_codes }
    )
  end

  let(:provider) { create(:provider, office_codes: ['AAAAAA']) }

  context 'user with office codes with access to service' do
    let(:allowed_office_codes) { provider.office_codes }

    it 'can access NSM' do
      visit nsm_applications_path
      expect(page).to have_content('Your claims')
    end

    it 'can access PAA' do
      visit prior_authority_applications_path
      expect(page).to have_content('Your applications')
    end
  end

  context 'user with office codes with access to neither NSM, PAA nor EOL' do
    let(:allowed_office_codes) { [] }

    it 'can not access NSM' do
      visit nsm_applications_path
      expect(page).to have_no_content('Your claims')
      expect(page).to have_current_path(new_provider_session_path)
    end

    it 'can not access PAA' do
      visit prior_authority_applications_path
      expect(page).to have_no_content('Your Applications')
      expect(page).to have_current_path(new_provider_session_path)
    end
  end
end
