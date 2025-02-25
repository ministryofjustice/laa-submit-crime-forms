require 'system_helper'

RSpec.describe 'Import claims' do
  before do
    visit provider_saml_omniauth_callback_path
    visit new_nsm_import_path
  end

  it 'lets me import a claim' do
    attach_file(file_fixture('import_sample.xml'))
    click_on 'Save and continue'
    expect(page).to have_content(
      'You imported 3 work items and 2 disbursements. ' \
      'To submit the claim, check the uploaded claim details and update any incomplete information.'
    )
  end

  it 'validates file type' do
    attach_file(file_fixture('test.json'))
    click_on 'Save and continue'
    expect(page).to have_content "The file must be of type 'XML'"
  end

  it 'handles unreadable files' do
    attach_file(file_fixture('unreadable_import.xml'))
    click_on 'Save and continue'
    expect(page).to have_content("ERROR: Element 'claim': Missing child element(s).")
  end
end
