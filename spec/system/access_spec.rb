require 'rails_helper'

RSpec.describe 'System Access', type: :system do
  before do
    visit provider_saml_omniauth_callback_path(
      info: { name: 'Test User', email: 'provider@example.com', office_codes: provider.office_codes }
    )
  end

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

    context 'selectes an alternative office code that does not have access' do
      it 'can access NSM' do
        visit nsm_applications_path
        expect(page).to have_content('Your claims')
      end

      it 'can access PAA' do
        visit prior_authority_applications_path
        expect(page).to have_content('Your applications')
      end
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

    context 'selectes an alternative office code that does not have access' do
      it 'can access NSM' do
        visit nsm_applications_path
        expect(page).to have_content('Your claims')
      end

      it 'can access PAA' do
        visit prior_authority_applications_path
        expect(page).to have_no_content('Your applications')
        expect(page).to have_current_path(root_path)
      end
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

    context 'selectes an alternative office code that does not have access' do
      it 'can not access NSM' do
        visit nsm_applications_path
        expect(page).to have_no_content('Your claims')
        expect(page).to have_current_path(root_path)
      end

      it 'can access PAA' do
        visit prior_authority_applications_path
        expect(page).to have_content('Your applications')
      end
    end
  end

  context 'user with office codes with access to neither NSM or PAA' do
    let(:provider) { create(:provider, office_codes: ['CCCCCC']) }

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

    context 'selectes an alternative office code that does not have access' do
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
end
