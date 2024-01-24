require 'rails_helper'

RSpec.describe 'Prior authority applications - add hearing details' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_root_path

    click_on 'Start an application'
    choose 'No'
    click_on 'Save and continue'

    choose 'No'
    click_on 'Save and continue'

    fill_in 'What is your unique file number?', with: '000000/123'
    click_on 'Save and continue'

    click_on 'Case contact'
    fill_in 'Full name', with: 'John Doe'
    fill_in 'Email address', with: 'john@does.com'
    fill_in 'Firm name', with: 'LegalCorp Ltd'
    fill_in 'Firm account number', with: 'A12345'
    click_on 'Save and continue'

    fill_in 'First name', with: 'John'
    fill_in 'Last name', with: 'Doe'
    within('.govuk-form-group', text: 'Date of birth') do
      fill_in 'Day', with: '27'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2000'
    end
    click_on 'Save and continue'

    fill_in 'What was the main offence', with: 'Supply a controlled drug of Class A - Heroin'
    within('.govuk-form-group', text: 'Date of representation order') do
      fill_in 'Day', with: '27'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2023'
    end

    fill_in 'MAAT number', with: '123456'
    within('.govuk-form-group', text: 'Is your client detained?') do
      choose 'No'
    end

    within('.govuk-form-group', text: 'Is this case subject to POCA (Proceeds of Crime Act 2002)?') do
      choose 'Yes'
    end

    click_on 'Save and continue'
  end

  it 'allows hearing detail creation' do
    expect(page).to have_title 'Hearing details'

    within('.govuk-form-group', text: 'Date of next hearing') do
      dt = Date.tomorrow
      fill_in 'Day', with: dt.day
      fill_in 'Month', with: dt.month
      fill_in 'Year', with: dt.year
    end

    within('.govuk-form-group', text: 'Likely or actual plea') do
      choose 'Not guilty'
    end
    within('.govuk-form-group', text: 'Type of court') do
      choose 'Central Criminal Court'
    end

    click_on 'Save and continue'
    expect(page).to have_content 'Case and hearing detailsCompleted'
  end

  it 'validates hearing detail fields' do
    click_on 'Save and continue'
    expect(page)
      .to have_content('Date cannot be blank')
      .and have_content('Select the likely or actual plea')
      .and have_content('Select the type of court')
  end

  it 'allows save and come back later' do
    click_on 'Save and come back later'
    expect(page).to have_content('Case and hearing detailsIn progress')
  end
end
