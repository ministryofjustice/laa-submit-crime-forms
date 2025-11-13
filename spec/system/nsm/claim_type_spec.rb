require 'rails_helper'

RSpec.describe 'User can fill in claim type details', :stub_app_store_search, :stub_oauth_token, type: :system do
  before do
    visit provider_entra_id_omniauth_callback_path
  end

  context 'when claim already exists' do
    let(:claim) { create(:claim, :case_type_magistrates) }

    it 'can do green path' do
      visit edit_nsm_steps_claim_type_path(claim.id)

      choose "Non-standard magistrates' court payment"
      click_on 'Save and continue'
      expect(page).to have_css('h1', text: "Non-standard magistrates' court payment")
    end

    it 'can navigate back from supplemental claim page and show correct type selected' do
      visit edit_nsm_steps_claim_type_path(claim.id)
      expect(page).to have_content 'What do you want to claim?'
      choose "Non-standard magistrates' - supplemental"
      click_on 'Save and continue'
      expect(page).to have_css('h1', text: 'Supplemental claims')
      click_on 'Back'
      expect(page).to have_content 'What do you want to claim?'
      nsm_checkbox = page.find('#nsm-steps-claim-type-form-claim-type-non-standard-magistrate-field')
      expect(nsm_checkbox.checked?).to be true
    end
  end

  context 'when creating a new claim' do
    before do
      visit nsm_applications_path
      click_on 'Start a new claim'
    end

    it 'can create a new non-standard mag payment' do
      ufn_value = '010124/001'
      choose "Non-standard magistrates' court payment"
      click_on 'Save and continue'
      expect(page).to have_css 'h1', text: "Non-standard magistrates' court payment"
      fill_in 'What is your unique file number (UFN)?', with: ufn_value
      fill_in 'Day', with: 1
      fill_in 'Month', with: 1
      fill_in 'Year', with: 2024
      click_on 'Save and continue'
      expect(page).to have_content 'Which firm office account number is this claim for?'
      click_on 'Back'
      ufn_input = page.find('#nsm-steps-details-form-ufn-field')
      expect(ufn_input.value).to eq ufn_value
    end

    it 'can create a new breach of injunction payment' do
      ufn_value = '010124/001'
      choose 'Breach of injunction'
      click_on 'Save and continue'
      expect(page).to have_css 'h1', text: 'Breach of injunction'
      fill_in 'What is your unique file number (UFN)?', with: ufn_value
      fill_in "Client's CNTP (contempt) number", with: '123456'
      fill_in 'Day', with: 1
      fill_in 'Month', with: 1
      fill_in 'Year', with: 2024
      click_on 'Save and continue'
      click_on 'Back'
      ufn_input = page.find('#nsm-steps-boi-details-form-ufn-field')
      expect(ufn_input.value).to eq ufn_value
    end

    it 'can navigate back from supplemental claim page' do
      choose "Non-standard magistrates' - supplemental"
      click_on 'Save and continue'
      expect(page).to have_css('h1', text: 'Supplemental claim')
      click_on 'Back'
      expect(page).to have_content 'What do you want to claim?'
    end

    it 'reloads page with error when no option selected' do
      click_on 'Save and continue'
      expect(page).to have_content 'What do you want to claim?'
      expect(page).to have_content 'Please select a claim type'
    end
  end
end
