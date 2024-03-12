require 'system_helper'

RSpec.describe 'Prior authority authentication' do
  context 'when user is not signed in' do
    it 'redirects the user to the sign-in page' do
      visit prior_authority_applications_path
      expect(page).to have_current_path '/login', ignore_query: true
    end
  end

  context 'when user is signed in' do
    before { visit provider_saml_omniauth_callback_path }

    it 'allows the user to access the page' do
      visit prior_authority_applications_path
      expect(page).to have_current_path prior_authority_applications_path, ignore_query: true
    end
  end
end
