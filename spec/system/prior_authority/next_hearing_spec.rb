require 'system_helper'

RSpec.describe 'Prior authority applications (prison law) - add next hearing' do
  context 'when navigation from tasklist' do
    before do
      fill_in_until_step(:your_application_progress, prison_law: 'Yes')
    end

    it 'allows next hearing detail creation' do
      expect(page).to have_content 'Case and hearing detailsNot started'
      click_on 'Case and hearing details'
      expect(page).to have_title 'Case and hearing details'

      choose 'Yes'
      within('.govuk-form-group', text: 'Date of next hearing', match: :first) do
        dt = Date.tomorrow
        fill_in 'Day', with: dt.day
        fill_in 'Month', with: dt.month
        fill_in 'Year', with: dt.year
      end

      click_on 'Save and continue'
      expect(page).to have_title 'Your application progress'
      expect(page).to have_content 'Case and hearing detailsCompleted'
    end

    it 'validates next hearing fields' do
      click_on 'Case and hearing details'
      click_on 'Save and continue'
      expect(page).to have_content('Select yes if you know the date of the next hearing')

      choose 'Yes'
      click_on 'Save and continue'
      expect(page).to have_content('Date cannot be blank')
    end
  end
end
