require 'rails_helper'

RSpec.describe 'Sign in user journey' do
  context 'user is not signed in' do
    it 'redirects to the login page' do
      visit '/'
      expect(current_url).to match('/login')
      expect(page).to have_content('You need to sign in or sign up before continuing')
    end
  end

  context 'user is signed in' do
    before do
      visit provider_saml_omniauth_callback_path
    end

    it 'authenticates the user and redirects to the dashboard' do
      expect(page).to have_current_path(root_path)
    end

    context 'when I start NSM journey' do
      before { click_on "Claim non-standard magistrates' court payments, previously CRM7" }

      it 'takes me to the application path page' do
        expect(page).to have_current_path(nsm_applications_path)
      end
    end

    context 'when I start PA journey' do
      before { click_on 'Apply for prior authority to incur disbursements, previously CRM4' }

      it 'takes me to the application path page' do
        expect(page).to have_current_path(prior_authority_applications_path)
      end
    end
  end

  context 'user has implicit permission from an all' do
    before do
      visit provider_saml_omniauth_callback_path
    end

    it 'authenticates the user and redirects to the dashboard' do
      expect(page).to have_current_path(root_path)
    end
  end
end
