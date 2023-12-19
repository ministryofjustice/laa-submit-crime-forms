require 'rails_helper'

RSpec.describe 'Sign in user journey' do
  # Do not leave left overs, as this test will persist
  # a mock provider to the database
  before(:all) do
    User.destroy_all
  end

  after(:all) do
    User.destroy_all
  end

  before do
    # allow_any_instance_of(
    #   Datastore::ApplicationCounters
    # ).to receive_messages(returned_count: 5)

    visit '/'
    click_on 'Start now'
  end

  context 'user is not signed in' do
    it 'redirects to the login page' do
      expect(current_url).to match('/login')
      expect(page).to have_content('Access restricted')
    end
  end

  context 'user signs in but is not yet enrolled' do
    before do
      allow(
        OmniAuth.config
      ).to receive(:mock_auth).and_return(
        saml: OmniAuth::AuthHash.new(info: { office_codes: ['1X000X'] })
      )

      click_button 'Sign in with LAA Portal'
    end

    it 'redirects to the error page' do
      expect(current_url).to match(laa_msf.not_enrolled_errors_path)
      expect(page).to have_content('Your account cannot use this service yet')
    end
  end

  context 'user is signed in, only has one account' do
    before do
      allow_any_instance_of(
        User
      ).to receive(:office_codes).and_return(['A1'])

      click_button 'Sign in with LAA Portal'
    end

    it 'authenticates the user and redirects to the dashboard' do
      expect(current_url).to match(applications_path)
    end
  end
end
