require 'system_helper'

RSpec.describe 'Prior authority applications - add case details', :javascript, type: :system do
  before do
    fill_in_until_step(:your_application_progress)
  end

  it 'allows case detail creation' do
    expect(page).to have_content 'Case and hearing details Not started'

    click_on 'Case and hearing details'
    expect(page).to have_title 'Case details'

    fill_in 'What was the main offence', with: 'Supply a controlled drug of Class A - Heroin'
    within('.govuk-form-group', text: 'Date of representation order') do
      fill_in 'Day', with: '27'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2023'
    end

    fill_in 'MAAT number', with: '123456'
    within('.govuk-form-group', text: 'Is your client detained?') do
      choose 'Yes'
      fill_in 'Where is your client detained?', with: 'HMP Bedford'
    end

    within('.govuk-form-group', text: 'Is this case subject to POCA (Proceeds of Crime Act 2002)?') do
      2.times { choose 'Yes' } # The first time may simply close the autocomplete suggestion box opened above
    end

    click_on 'Save and continue'
    expect(page).to have_content 'Hearing details'
  end

  it 'validates client detail fields' do
    click_on 'Case and hearing details'
    click_on 'Save and continue'
    expect(page)
      .to have_content('Enter the main offence')
      .and have_content('Date cannot be blank')
      .and have_content('Enter the MAAT number')
      .and have_content('Select yes if your client is detained')
      .and have_no_content('Enter the name of the prison')
      .and have_content('Select yes if this case is subject to POCA (Proceeds of Crime Act 2002)?')

    within('.govuk-form-group', text: 'Is your client detained?') do
      choose 'Yes'
    end

    click_on 'Save and continue'
    expect(page).to have_content 'Enter the name of the prison'
  end

  it 'allows save and come back later' do
    click_on 'Case and hearing details'

    click_on 'Save and come back later'
    expect(page).to have_content 'Your applications'
  end
end
