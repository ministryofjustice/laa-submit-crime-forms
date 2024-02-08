require 'system_helper'

RSpec.describe 'Prior authority applications - travel costs' do
  before do
    fill_in_until_step(:primary_quote_summary)
  end

  context 'when the user has entered nothing' do
    it 'shows I have added nothing' do
      expect(page).to have_content 'No travel costs added'
    end
  end

  context 'when the user clicks through to the travel details page' do
    before do
      within '#travel-cost-summary' do
        click_on 'Change'
      end
    end

    context 'when user fills in valid information' do
      before do
        fill_in 'Why are there travel costs if your client is not detained?', with: 'because'
        fill_in 'Hours', with: 0
        fill_in 'Minutes', with: 30
        fill_in 'Hourly cost', with: 3.21
      end

      it 'allows user to enter information and progress' do
        click_on 'Save and continue'
        expect(page).to have_title 'Primary quote summary'
      end

      it 'allows user to enter information and come back later' do
        click_on 'Save and come back later'
        expect(page).to have_title 'Your applications'
      end

      it 'allows user to view calculation' do
        click_on 'Update calculation'
        expect(page).to have_content 'Total cost £1.61'
      end
    end

    it 'validates appropriately' do
      click_on 'Save and continue'
      expect(page).to have_title 'Error: Travel cost'
    end
  end

  context 'when the user has entered travel costs' do
    before do
      within '#travel-cost-summary' do
        click_on 'Change'
      end
      fill_in 'Why are there travel costs if your client is not detained?', with: 'because'
      fill_in 'Hours', with: 0
      fill_in 'Minutes', with: 30
      fill_in 'Hourly cost', with: 3.22
      click_on 'Save and continue'
    end

    context 'when I click to delete travel costs' do
      before do
        within '#travel-cost-summary' do
          click_on 'Delete'
        end
      end

      it 'lets me delete travel costs' do
        click_on 'Yes, delete it'
        expect(page).to have_content 'No travel costs added'
      end

      it 'lets me abort deleting travel costs' do
        click_on 'No, do not delete it'
        expect(page).to have_content 'Primary quote summary'
        expect(page).to have_content '£1.61'
      end
    end
  end
end
