require 'system_helper'

RSpec.describe 'Prior authority applications - add client details' do
  before do
    fill_in_until_step(:your_application_progress)
  end

  it 'allows client detail creation' do
    expect(page).to have_content 'Client details Not yet started'
    click_on 'Client details'
    expect(page).to have_title 'Client details'

    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    within('.govuk-form-group', text: 'Date of birth') do
      fill_in 'Day', with: '27'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2000'
    end

    click_on 'Save and continue'

    expect(page).to have_content 'Your application progress'
  end

  it 'validates client detail fields' do
    expect(page).to have_content 'Client details Not yet started'
    click_on 'Client details'

    click_on 'Save and continue'
    expect(page).to have_content "Enter the client's first name"
    expect(page).to have_content "Enter the client's last name"
    expect(page).to have_content "Enter the client's date of birth"
  end

  it 'validates non-numerical date fields' do
    click_on 'Client details'
    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    within('.govuk-form-group', text: 'Date of birth') do
      fill_in 'Day', with: '27'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: 'Two thousand'
    end

    click_on 'Save and continue'
    expect(page).to have_content 'The year must include 4 numbers'
  end

  it 'allows save and come back later' do
    expect(page).to have_content 'Client details Not yet started'
    click_on 'Client details'

    click_on 'Save and come back later'
    expect(page).to have_content 'Your applications'
  end
end
