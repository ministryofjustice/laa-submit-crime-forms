require 'system_helper'

RSpec.describe 'Prior authority applications - additional costs' do
  context 'when I visit the quote summary screen' do
    before do
      fill_in_until_step(:primary_quote_summary)
    end

    context 'when I click through to additional costs' do
      before do
        within('#additional-cost-summary') { click_on 'Change' }
      end

      it 'allows me to add an additional cost' do
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
        choose 'Charged per item'
        fill_in 'Number of items', with: '12'
        fill_in 'What is the cost per item?', with: '0.10'
        click_on 'Update calculation'

        expect(page).to have_content '£1.20'
      end

      context 'When I have added a cost' do
        before do
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
          expect(page).to have_content 'Do you want to add another additional cost?'
        end

        it 'allows me to travel between quote summary and cost summary' do
          choose 'No'
          click_on 'Save and continue'
          expect(page).to have_title 'Primary quote summary'
          within('#additional-cost-summary') { click_on 'Change' }
          expect(page).to have_title "You've added 1 additional cost"
        end

        it 'allows me to add a second cost' do
          choose 'Yes'
          click_on 'Save and continue'
          fill_in 'What is the additional cost for?', with: 'Dancing'
          fill_in 'Why is the additional cost required?', with: 'It is tiring'
          choose 'Charged by the hour'
          fill_in 'Hours', with: '1'
          fill_in 'Minutes', with: '30'
          fill_in 'What is the hourly cost?', with: '25'
          click_on 'Save and continue'

          expect(page).to have_title "You've added 2 additional costs"
        end

        it 'detects that I am in an invalid state' do
          choose 'Yes'
          click_on 'Save and continue'
          click_on 'Back' # to quote summary screen
          click_on 'Save and continue' # to application progress screen
          expect(page).to have_content 'Primary quote In progress'
        end
      end

      it 'validates if forms left blank' do
        choose 'Charged per item'
        click_on 'Save and continue'
        expect(page).to have_title 'Additional cost'
        expect(page).to have_content 'Enter what the additional cost is for'
      end

      it 'validates if forms are invalid' do
        choose 'Charged by the hour'
        fill_in 'Hours', with: '0'
        fill_in 'Minutes', with: '61'
        click_on 'Save and continue'
        expect(page).to have_title 'Additional cost'
        expect(page).to have_content 'The number of minutes must be between 0 and 59'
      end
    end
  end
end
