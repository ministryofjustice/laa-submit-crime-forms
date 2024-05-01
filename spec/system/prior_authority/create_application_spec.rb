require 'system_helper'

RSpec.describe 'Prior authority application creation' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_applications_path
  end

  it 'allows the user to create an application' do
    click_on 'Make a new application'

    expect(page).to have_content 'Is this a Prison Law matter?'
    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £500?'
    choose 'No'
    click_on 'Save and continue'

    fill_in 'What is your unique file number (UFN)?', with: '070324/123'
    click_on 'Save and continue'

    expect(page).to have_content 'Your application progress'
    click_on 'Back to your applications'
    click_on 'Drafts'
    expect(page).to have_content '070324/123'
  end

  it 'performs validations' do
    click_on 'Make a new application'

    click_on 'Save and continue'
    expect(page).to have_content 'Select yes if this is a Prison Law matter'
    choose 'Yes'
    click_on 'Save and continue'

    click_on 'Save and continue'
    expect(page).to have_content 'Select yes if you are applying for a total authority of less than £500'
    choose 'No'
    click_on 'Save and continue'

    click_on 'Save and continue'
    expect(page).to have_content 'Enter the unique file number'
  end

  it 'offboards the user for authority request of less than £500' do
    click_on 'Make a new application'

    choose 'Yes'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £500?'
    choose 'Yes'
    click_on 'Save and continue'
    expect(page).to have_title 'You do not need to apply'
    expect(page)
      .to have_content 'to incur disbursements for a Prison Law matter if the total authority is less than £500.'
  end

  it 'offboards the user for authority request of less than £100' do
    click_on 'Make a new application'

    choose 'No'
    click_on 'Save and continue'

    expect(page).to have_content 'Are you applying for a total authority of less than £100?'
    choose 'Yes'
    click_on 'Save and continue'
    expect(page).to have_title 'You do not need to apply'
    expect(page)
      .to have_content 'to incur disbursements if the total authority is less than £100.'
  end

  context 'when I have a single office code' do
    before do
      Provider.first.update(office_codes: %w[1A123B])
    end

    it 'stores my office code against the application' do
      click_on 'Make a new application'
      expect(PriorAuthorityApplication.first.office_code).to eq '1A123B'
    end
  end

  context 'when I have multiple office codes' do
    before do
      Provider.first.update(office_codes: %w[1A123B 1K022G])
    end

    it 'leaves the office code blank for now' do
      click_on 'Make a new application'
      expect(PriorAuthorityApplication.first.office_code).to be_nil
    end
  end
end
