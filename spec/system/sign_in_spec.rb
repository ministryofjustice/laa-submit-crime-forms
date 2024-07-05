require 'rails_helper'

RSpec.describe 'Sign in user journey' do
  before do
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

  let(:office_codes_from_crm4_config) { ['1A111A'] }
  let(:office_codes_from_crm5_config) { ['1A111A'] }
  let(:office_codes_from_crm7_config) { ['1A111A'] }

  context 'user is not signed in' do
    it 'redirects to the login page' do
      visit '/'
      expect(current_url).to match('/login')
      expect(page).to have_content('You need to sign in or sign up before continuing')
    end
  end

  context 'user signs in but is not yet enrolled' do
    before do
      visit provider_saml_omniauth_callback_path
    end

    # NOTE: test relies on mock_auth having office code of "1A123B"
    let(:office_codes_from_crm4_config) { ['1X000X'] }
    let(:office_codes_from_crm5_config) { ['1X000X'] }
    let(:office_codes_from_crm7_config) { ['1X000X'] }

    it 'redirects to the error page' do
      expect(current_url).to match(laa_msf.not_enrolled_errors_path)
      expect(page).to have_content('Your account cannot use this service yet')
    end
  end

  context 'user is signed in' do
    before do
      visit provider_saml_omniauth_callback_path
    end

    # NOTE: test relies on mock_auth having office code of "1A123B"
    let(:office_codes_from_crm4_config) { ['1A123B'] }
    let(:office_codes_from_crm5_config) { ['1A123B'] }
    let(:office_codes_from_crm7_config) { ['1A123B'] }

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

    context 'when office codes are deactivated when user is already signed in' do
      before do
        allow(Rails.configuration.x.inactive_offices)
          .to receive(:inactive_office_codes)
          .and_return(['1A123B'])
      end

      context 'when I start NSM journey' do
        before { click_on "Claim non-standard magistrates' court payments, previously CRM7" }

        it 'takes me to an error page' do
          expect(page).to have_current_path(errors_inactive_offices_path)
        end
      end
    end
  end

  context 'user has implicit permission from an all' do
    before do
      visit provider_saml_omniauth_callback_path
    end

    # NOTE: test relies on mock_auth having office code of "1A123B"
    let(:office_codes_from_crm4_config) { ['AAAAA'] }
    let(:office_codes_from_crm5_config) { ['ALL'] }
    let(:office_codes_from_crm7_config) { ['BBBBB'] }

    it 'authenticates the user and redirects to the dashboard' do
      expect(page).to have_current_path(root_path)
    end
  end
end
