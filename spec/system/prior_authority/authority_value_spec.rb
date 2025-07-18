require 'system_helper'

RSpec.describe 'Prior authority applications - add authority value', :stub_app_store_search, :stub_oauth_token do
  before do
    visit provider_entra_id_omniauth_callback_path
    visit prior_authority_applications_path
    click_on 'Make a new application'
  end

  context 'when application relates to a prison law matter' do
    it 'sets authority threshold to £500' do
      expect(page).to have_content 'Is this a Prison Law matter?'

      choose 'Yes'
      click_on 'Save and continue'
      expect(page).to have_content 'Are you applying for a total authority of less than £500?'

      click_on 'Save and continue'
      expect(page)
        .to have_content 'Select yes if you are applying for a total authority of less than £500'

      choose 'No'
      click_on 'Save and continue'
      expect(page).to have_title 'Unique file number'
    end
  end

  context 'when application does not relate to a prison law matter' do
    it 'sets authority threshold to £500' do
      expect(page).to have_content 'Is this a Prison Law matter?'
      choose 'No'
      click_on 'Save and continue'
      expect(page).to have_content 'Are you applying for a total authority of less than £100?'

      click_on 'Save and continue'
      expect(page)
        .to have_content 'Select yes if you are applying for a total authority of less than £100'

      choose 'No'
      click_on 'Save and continue'
      expect(page).to have_title 'Unique file number'
    end
  end
end
