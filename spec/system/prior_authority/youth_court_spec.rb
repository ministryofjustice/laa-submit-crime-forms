require 'system_helper'

RSpec.describe 'Prior authority applications - add youth court' do
  before do
    fill_in_until_step(:youth_court, court_type: "Magistrates' court")
  end

  context 'when youth court matter question answered' do
    it 'navigates to Your application page' do
      choose 'Yes'
      click_on 'Save and continue'
      expect(page).to have_title 'Your application progress'
      expect(page).to have_content 'Case and hearing details Completed'
    end
  end

  context 'when youth court matter question not answered' do
    it 'displays expected error' do
      click_on 'Save and continue'
      expect(page).to have_content 'Select yes if this is a youth court matter'
    end
  end
end
