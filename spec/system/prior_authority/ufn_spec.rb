require 'system_helper'

RSpec.describe 'Prior authority applications - add Unique file number' do
  context 'when starting a new application' do
    before do
      fill_in_until_step(:ufn)
    end

    it 'has the expected content' do
      expect(page).to have_title 'Unique file number'
      expect(page).to have_content 'What is your unique file number (UFN)?'
    end

    it 'allows me to go back to the authority value question' do
      click_on 'Back'
      expect(page).to have_title('Authority value')
    end

    it 'allows me to save and continue' do
      fill_in 'What is your unique file number (UFN)?', with: '111111/111'
      click_on 'Save and continue'
      expect(page).to have_title 'Your application progress'
    end
  end

  context 'when coming from the tasklist' do
    before do
      fill_in_until_step(:your_application_progress)
      click_on 'Unique file number'
    end

    it 'allows me to go back to the tasklist' do
      expect(page).to have_title 'Unique file number'
      click_on 'Back'
      expect(page).to have_title 'Your application progress'
    end
  end

  context 'when coming from the check your answers page' do
    before do
      fill_in_until_step(:submit_application)
      click_on 'Submit application'
      within('.govuk-summary-card', text: 'Application details') do
        click_on 'Change'
      end
    end

    it 'allows me to go back to the check answers page' do
      expect(page).to have_title 'Unique file number'
      click_on 'Back'
      expect(page).to have_title 'Check your answers'
    end
  end
end
