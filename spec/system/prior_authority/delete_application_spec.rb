require 'rails_helper'

RSpec.describe 'Prior authority application deletion' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_root_path
    click_on 'Start an application'
    choose 'Yes'
    click_on 'Save and continue'

    choose 'No'
    click_on 'Save and continue'

    fill_in 'What is your unique file number?', with: '000000/123'
    click_on 'Save and continue'

    click_on 'Back to applications'
  end

  it 'allows the user to delete an application' do
    click_on 'Delete'
    expect(page).to have_content 'Are you sure you want to delete this draft application?'
    click_on 'Yes, delete it'
    expect(page).to have_no_content '000000/123'
  end

  it 'allows the user to cancel deleting an application' do
    click_on 'Delete'
    expect(page).to have_content 'Are you sure you want to delete this draft application?'
    click_on 'No, do not delete it'
    expect(page).to have_content '000000/123'
  end
end
