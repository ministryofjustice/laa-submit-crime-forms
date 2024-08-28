require 'rails_helper'

RSpec.describe 'Notification banner' do
  before do
    visit provider_saml_omniauth_callback_path
  end

  context 'when there is a notifcation banner to be displayed' do
    before do
      allow(Rails.configuration.x.notification_banner).to receive(:notification).and_return(config)
    end

    let(:config) do
      {
        message: 'My notification banner',
        date_from: 1.day.ago.to_s,
        date_to: 1.day.since.to_s
      }
    end

    it 'shows the banner on the change service page' do
      visit root_path
      expect(page).to have_content('My notification banner')
    end

    it 'shows the banner on the claims index page' do
      visit nsm_applications_path
      expect(page).to have_content('My notification banner')
    end

    it 'shows the banner on the prior authority index page' do
      visit prior_authority_applications_path
      expect(page).to have_content('My notification banner')
    end
  end

  context 'when there is no notifcation banner to be displayed' do
    before do
      allow(Rails.configuration.x).to receive(:notification_banner).and_return(nil)
    end

    it 'shows no banner' do
      visit root_path
      expect(page)
        .to have_no_content('Important')
        .and have_no_selector('.govuk-notification-banner')

      visit nsm_applications_path
      expect(page)
        .to have_no_content('Important')
        .and have_no_selector('.govuk-notification-banner')

      visit prior_authority_applications_path
      expect(page)
        .to have_no_content('Important')
        .and have_no_selector('.govuk-notification-banner')
    end
  end

  context 'when the notifcation banner has expired' do
    before do
      allow(Rails.configuration.x.notification_banner).to receive(:notification).and_return(config)
    end

    around do |example|
      travel_to(date_to + 1.minute) do
        example.run
      end
    end

    let(:date_to) { 1.day.since }

    let(:config) do
      {
        message: 'My notification banner',
        date_from: 1.day.ago.to_s,
        date_to: date_to.to_s
      }
    end

    it 'shows no banner' do
      visit root_path
      expect(page)
        .to have_no_content('Important')
        .and have_no_selector('.govuk-notification-banner')

      visit nsm_applications_path
      expect(page)
        .to have_no_content('Important')
        .and have_no_selector('.govuk-notification-banner')

      visit prior_authority_applications_path
      expect(page)
        .to have_no_content('Important')
        .and have_no_selector('.govuk-notification-banner')
    end
  end
end
