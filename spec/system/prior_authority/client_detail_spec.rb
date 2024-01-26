require 'system_helper'

RSpec.describe 'Prior authority applications - add client details' do
  before do
    fill_in_until_step(:your_application_progress)
  end

  it 'allows client detail creation' do
    expect(page).to have_content 'Client detailsNot started'
    click_on 'Client details'
    expect(page).to have_title 'Client details'

    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    within('.govuk-form-group', text: 'Date of birth') do
      fill_in 'Day', with: '27'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2000'
    end

    click_on 'Save and come back later'

    expect(page).to have_content 'Client detailsCompleted'

    click_on 'Client details'
    click_on 'Save and continue'
  end

  it 'validates client detail fields' do
    expect(page).to have_content 'Client detailsNot started'
    click_on 'Client details'

    click_on 'Save and continue'
    expect(page).to have_content "Enter the client's first name"
    expect(page).to have_content "Enter the client's last name"
    expect(page).to have_content "Enter the client's date of birth"
  end

  it 'allows save and come back later' do
    expect(page).to have_content 'Client detailsNot started'
    click_on 'Client details'

    click_on 'Save and come back later'
    expect(page).to have_content 'Client detailsIn progress'
  end
end
