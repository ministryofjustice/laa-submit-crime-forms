require 'system_helper'

RSpec.describe 'Prior authority application lists', :javascript do
  before do
    visit provider_saml_omniauth_callback_path
    create(:prior_authority_application, laa_reference: 'LAA-AAAAA', status: 'submitted', provider: Provider.first)
    create(:prior_authority_application, laa_reference: 'LAA-BBBBB', status: 'submitted', provider: Provider.first)
    create(:prior_authority_application, laa_reference: 'LAA-CCCCC', status: 'granted', provider: Provider.first)
    create(:prior_authority_application, laa_reference: 'LAA-DDDDD', status: 'draft', provider: Provider.first)

    visit prior_authority_root_path
  end

  it 'only shows submitted applications on the submitted tab' do
    click_on 'Submitted'
    find('.govuk-table__cell', text: 'LAA-AAAAA') # Hack to force capybara to wait for JS load
    expect(page).to have_content 'AAAAA'
    expect(page).to have_content 'BBBBB'
    expect(page).to have_no_content 'CCCCC'
    expect(page).to have_no_content 'DDDDD'
  end

  it 'allows sorting by columns in ascending and descending order' do
    click_on 'Submitted'
    find('.govuk-table__cell', text: 'LAA-AAAAA') # Hack to force capybara to wait for JS load
    click_on 'LAA reference'
    find('th[aria-sort="ascending"]')
    expect(page.body).to match(/AAAAA.*BBBBB.*/m)
    click_on 'LAA reference'
    find('th[aria-sort="descending"]')
    expect(page.body).to match(/BBBBB.*AAAAA.*/m)
  end

  it 'only shows draft applications on the drafts tab' do
    click_on 'Drafts'
    find('.govuk-table__cell', text: 'LAA-DDDDD') # Hack to force capybara to wait for JS load
    expect(page).to have_no_content 'AAAAA'
    expect(page).to have_no_content 'BBBBB'
    expect(page).to have_no_content 'CCCCC'
    expect(page).to have_content 'DDDDD'
  end

  it 'only shows assessed applications on the assessed tab' do
    click_on 'Assessed'
    find('.govuk-table__cell', text: 'LAA-CCCCC') # Hack to force capybara to wait for JS load
    expect(page).to have_no_content 'AAAAA'
    expect(page).to have_no_content 'BBBBB'
    expect(page).to have_content 'CCCCC'
    expect(page).to have_no_content 'DDDDD'
  end
end
