require 'system_helper'

RSpec.describe 'Prior authority applications - add psychiatric liaison' do
  before do
    fill_in_until_step(:psychiatric_liaison, court_type: 'Central Criminal Court')
  end

  context 'when psychiatric liaison service has been used' do
    it 'navigates to Your application page' do
      choose 'Yes'
      click_on 'Save and continue'
      expect(page).to have_title 'Your application progress'
    end
  end

  context 'when psychiatric liaison service has not been used and reason given' do
    it 'navigates to Your application page' do
      choose 'No'
      fill_in 'Explain why you did not access this service', with: 'whatever'
      click_on 'Save and continue'
      expect(page).to have_title 'Your application progress'
    end
  end

  context 'when psychiatric liaison service question not answered' do
    it 'displays expected error' do
      click_on 'Save and continue'
      expect(page).to have_content 'Select yes if you have accessed the psychiatric liason service'
    end
  end

  context 'when psychiatric liaison service has not been used BUT no reason given' do
    it 'displays expected error' do
      choose 'No'
      click_on 'Save and continue'
      expect(page).to have_content 'Explain why you did not access the psychiatric liaison service'
    end
  end
end
