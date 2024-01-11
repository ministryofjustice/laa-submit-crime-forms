require 'rails_helper'

RSpec.describe 'Prior authority application creation' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_root_path
  end

  it 'allows the user to create an application' do
    click_on 'Start an application'

    expect(page).to have_content 'Is this a Prison Law matter?'
    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £500?'
    choose 'No'
    click_on 'Save and continue'

    fill_in 'What is your unique file number?', with: '000000/123'
    click_on 'Save and continue'

    expect(page).to have_content 'Your application progress'
    click_on 'Back to your applications'

    expect(page).to have_content '000000/123'
  end

  it 'performs validations' do
    click_on 'Start an application'

    click_on 'Save and continue'
    expect(page).to have_content 'Select yes if this is a Prison Law matter'
    choose 'Yes'
    click_on 'Save and continue'

    click_on 'Save and continue'
    expect(page).to have_content 'Select if you are applying for a total authority of less than £500'
    choose 'No'
    click_on 'Save and continue'

    click_on 'Save and continue'
    expect(page).to have_content 'Enter your unique file number for this application'
  end

  it 'offboards the user for small-value authorities' do
    click_on 'Start an application'

    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £500?'
    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'You do not need to apply'
  end
end
