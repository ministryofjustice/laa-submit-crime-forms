require 'system_helper'

RSpec.describe 'Prior authority applications - additional costs' do
  context 'when I visit the appropriate screen' do
    before do
      fill_in_until_step(:travel)
      # TODO: When there is a UI path to this screen, remove this:
      visit current_path.gsub('/youth_court', '/additional_costs')

      expect(page).to have_title 'Do you want to add additional costs?'
    end

    it 'allows me to add an additional cost' do
      choose 'Yes'
      click_on 'Save and continue'
      expect(page).to have_title 'Additional cost'
      fill_in 'What is the additional cost for?', with: 'Printing'
      fill_in 'Why is the additional cost required?', with: 'Lots of paper'
      choose 'Charged per item'
      fill_in 'Number of items', with: '12'
      fill_in 'What is the cost per item?', with: '0.01'
      click_on 'Save and continue'

      expect(page).to have_content "You've added 1 additional cost"
      expect(page).to have_content 'Printing'
      expect(page).to have_content '£0.12'
    end

    it 'allows me to recalculate an additional cost' do
      choose 'Yes'
      click_on 'Save and continue'
      choose 'Charged per item'
      fill_in 'Number of items', with: '12'
      fill_in 'What is the cost per item?', with: '0.10'
      click_on 'Update calculation'

      expect(page).to have_content '£1.20'
    end

    context 'When I have added a cost' do
      before do
        choose 'Yes'
        click_on 'Save and continue'
        fill_in 'What is the additional cost for?', with: 'Printing'
        fill_in 'Why is the additional cost required?', with: 'Lots of paper'
        choose 'Charged per item'
        fill_in 'Number of items', with: '12'
        fill_in 'What is the cost per item?', with: '0.01'
        click_on 'Save and continue'
      end

      it 'allows me to edit a cost' do
        click_on 'Change'

        choose 'Charged by the hour'
        fill_in 'Hours', with: '1'
        fill_in 'Minutes', with: '30'
        fill_in 'What is the hourly cost?', with: '25'
        click_on 'Save and continue'

        expect(page).to have_content "You've added 1 additional cost"
        expect(page).to have_content 'Printing'
        expect(page).to have_content '£37.50'
      end

      it 'allows me to remove a cost' do
        click_on 'Delete'
        expect(page).to have_content 'Are you sure you want to delete this additional cost?'
        click_on 'Yes, delete it'
        expect(page).to have_content 'Do you want to add additional costs?'
      end
    end

    it 'allows user to say no' do
      choose 'No'
      click_on 'Save and continue'
      expect(page).to have_title 'Your application progress'
    end

    it 'validates if forms left blank' do
      click_on 'Save and continue'
      expect(page).to have_title 'Do you want to add additional costs?'
      expect(page).to have_content 'Select yes if you want to add additional costs'

      choose 'Yes'
      click_on 'Save and continue'
      choose 'Charged per item'
      click_on 'Save and continue'
      expect(page).to have_title 'Additional cost'
      expect(page).to have_content 'Enter what the additional cost is for'
    end
  end

  context 'when I have previously entered travel costs' do
    before do
      fill_in_until_step(:travel)
      # TODO: When there is a UI path to this screen, remove this:
      visit current_path.gsub('/youth_court', '/travel')

      choose 'Yes'
      click_on 'Save and continue'

      fill_in 'Why are there travel costs if your client is not detained?', with: 'because'
      fill_in 'Hours', with: 0
      fill_in 'Minutes', with: 30
      fill_in 'Hourly cost', with: 3.21
      click_on 'Save and continue'
      expect(page).to have_title 'Do you want to add additional costs?'
    end

    it 'handles the back button' do
      click_on 'Back'
      expect(page).to have_title 'Travel cost'
    end
  end
end
