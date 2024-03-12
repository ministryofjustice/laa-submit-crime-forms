require 'system_helper'

RSpec.describe 'Prior authority application lists' do
  before do
    visit provider_saml_omniauth_callback_path
    create(:prior_authority_application,
           :full,
           laa_reference: 'LAA-AAAAA',
           ufn: '120423/818',
           status: 'submitted',
           updated_at: 1.day.ago)
    create(:prior_authority_application, laa_reference: 'LAA-BBBBB', status: 'submitted', updated_at: 2.days.ago)
    create(:prior_authority_application, laa_reference: 'LAA-CCCCC', status: 'granted', updated_at: 3.days.ago)
    create(:prior_authority_application, laa_reference: 'LAA-DDDDD', status: 'draft', updated_at: 4.days.ago)
    create(:prior_authority_application, laa_reference: 'LAA-EEEEE', status: 'draft', office_code: 'OTHER')

    visit prior_authority_applications_path
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

  it 'shows most recently updated at the top by default' do
    within '#submitted' do
      expect(page.body).to match(/AAAAA.*BBBBB.*/m)
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

  it 'does not show applications from other offices' do
    expect(page).to have_no_content 'EEEEE'
  end

  it 'links through to a readonly summary page for submitted applications' do
    click_on '120423/818'
    expect(page).to have_content 'Application details'
    expect(page).to have_content 'LAA-AAAAA'
    within 'main.govuk-main-wrapper' do
      expect(page).to have_no_content 'Change'
    end
    expect(page).to have_content 'Email the LAA case team'
  end
end
