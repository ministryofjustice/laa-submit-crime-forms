require 'rails_helper'

RSpec.describe 'Prior authority applications - add case contact' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_root_path
    click_on 'Start an application'

    expect(page).to have_content 'Is this a Prison Law matter?'
    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £500?'

    choose 'No'
    click_on 'Save and continue'

    fill_in 'What is your unique file number?', with: '000000/123'
    click_on 'Save and continue'
  end

  it 'allows contact detail creation' do
    expect(page).to have_content 'Case contactNot started'

    click_on 'Case contact'
    fill_in 'Full name', with: 'John Doe'
    fill_in 'Email address', with: 'john@does.com'
    fill_in 'Firm name', with: 'LegalCorp Ltd'
    fill_in 'Firm account number', with: 'A12345'
    click_on 'Save and come back later'

    expect(page).to have_content 'Case contactCompleted'

    click_on 'Case contact'
    click_on 'Save and continue'
    expect(page).to have_title 'Client details'
  end

  it 'does validations' do
    expect(page).to have_content 'Case contactNot started'

    click_on 'Case contact'
    click_on 'Save and continue'

    expect(page).to have_content 'Enter the full contact name'
  end

  it 'allows save and come back later' do
    expect(page).to have_content 'Case contactNot started'

    click_on 'Case contact'
    click_on 'Save and come back later'

    expect(page).to have_content 'Case contactIn progress'
  end
end
