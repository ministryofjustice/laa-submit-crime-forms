require 'rails_helper'

RSpec.describe 'System Access', type: :system do
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

    visit provider_saml_omniauth_callback_path(
      info: { name: 'Test User', email: 'provider@example.com', office_codes: provider.office_codes }
    )
  end

  let(:office_codes_from_crm4_config) { ['BBBBBB'] }
  let(:office_codes_from_crm5_config) { ['CCCCCC'] }
  let(:office_codes_from_crm7_config) { ['AAAAAA'] }

  context 'user with office codes with access to NSM and PAA' do
    let(:provider) { create(:provider, :paa_access, :nsm_access) }

    it 'can access NSM' do
      visit nsm_applications_path
      expect(page).to have_content('Your claims')
    end

    it 'can access PAA' do
      visit prior_authority_applications_path
      expect(page).to have_content('Your applications')
    end
  end

  context 'user with office codes with access to NSM only' do
    let(:provider) { create(:provider, :nsm_access) }

    it 'can access NSM' do
      visit nsm_applications_path
      expect(page).to have_content('Your claims')
    end

    it 'can access PAA' do
      visit prior_authority_applications_path
      expect(page).to have_no_content('Your applications')
      expect(page).to have_current_path(root_path)
    end

    it 'can view NSM link on home page' do
      visit root_path
      expect(page).to have_content "Claim non-standard magistrates' court payments"
    end

    it 'cannot view PAA link on home page' do
      visit root_path
      expect(page).to have_no_content 'Apply for prior authority to incur disbursements'
    end

    it 'cannot view EOL link on home page' do
      visit root_path
      expect(page).to have_no_content 'Apply for extension of upper limits'
    end
  end

  context 'user with office codes with access to PAA only' do
    let(:provider) { create(:provider, :paa_access) }

    it 'can not access NSM' do
      visit nsm_applications_path
      expect(page).to have_no_content('Your claims')
      expect(page).to have_current_path(root_path)
    end

    it 'can access PAA' do
      visit prior_authority_applications_path
      expect(page).to have_content('Your applications')
    end

    it 'cannot view NSM link on home page' do
      visit root_path
      expect(page).to have_no_content "Claim non-standard magistrates' court payments"
    end

    it 'can view PAA link on home page' do
      visit root_path
      expect(page).to have_content 'Apply for prior authority to incur disbursements'
    end

    it 'cannot view EOL link on home page' do
      visit root_path
      expect(page).to have_no_content 'Apply for extension of upper limits'
    end
  end

  context 'user with office codes with access to neither NSM, PAA nor EOL' do
    let(:provider) { create(:provider, office_codes: ['DDDDD']) }

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

  context 'user with office codes with access to EOL only' do
    let(:provider) { create(:provider, :eol_access) }

    it 'cannot access NSM' do
      visit nsm_applications_path
      expect(page).to have_no_content('Your claims')
      expect(page).to have_current_path(root_path)
    end

    it 'cannot access PAA' do
      visit prior_authority_applications_path
      expect(page).to have_current_path(root_path)
    end

    it 'cannot view NSM link on home page' do
      visit root_path
      expect(page).to have_no_content "Claim non-standard magistrates' court payments"
    end

    it 'cannot view PAA link on home page' do
      visit root_path
      expect(page).to have_no_content 'Apply for prior authority to incur disbursements'
    end

    it 'can view EOL link on home page' do
      visit root_path
      expect(page).to have_content 'Apply for extension of upper limits'
    end
  end
end
