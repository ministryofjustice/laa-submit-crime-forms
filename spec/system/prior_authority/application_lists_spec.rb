require 'system_helper'

RSpec.describe 'Prior authority application lists' do
  before do
    visit provider_saml_omniauth_callback_path
    create(:prior_authority_application, laa_reference: 'LAA-AAAAA', status: 'submitted', provider: Provider.first)
    create(:prior_authority_application, laa_reference: 'LAA-BBBBB', status: 'submitted', provider: Provider.first)
    create(:prior_authority_application, laa_reference: 'LAA-CCCCC', status: 'granted', provider: Provider.first)
    create(:prior_authority_application, laa_reference: 'LAA-DDDDD', status: 'draft', provider: Provider.first)

    visit prior_authority_root_path
  end

  it 'only shows right applications in the right tabs' do
    within '#submitted' do
      expect(page).to have_content 'AAAAA'
      expect(page).to have_content 'BBBBB'
    end

    within '#assessed' do
      expect(page).to have_content 'CCCCC'
    end

    within '#drafts' do
      expect(page).to have_content 'DDDDD'
    end
  end

  it 'allows sorting by columns in ascending and descending order' do
    within '#submitted' do
      click_on 'LAA reference'
    end
    expect(page.body).to match(/AAAAA.*BBBBB.*/m)
    click_on 'LAA reference'
    expect(page.body).to match(/BBBBB.*AAAAA.*/m)
  end
end
