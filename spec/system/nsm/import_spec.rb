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

  context 'defendants import' do
    before do
      attach_file(file_fixture('import_sample_with_missing_fields.xml'))
      # progress to defendant details form
      click_on 'Save and continue' # 'What you are claiming for'
      click_on 'Save and continue' # 'Which firm office account number is this claim for?'
      click_on 'Save and continue' # 'Was this case worked on in an office in an undesignated area?'
      click_on 'Save and continue' # 'Is the first court that heard this case in an undesignated area?'
      click_on 'Firm details' # 'Your claim progress'
      click_on 'Save and continue' # 'Firm details'
      click_on 'Save and continue' # 'Contact details'
    end

    it 'shows defendant info incomplete message and updates messageing after corrections' do
      expect(page).to have_content('2 defendants have missing or incomplete information: defendant 1, defendant 2')
      first(:link_or_button, 'defendant 1').click
      fill_in 'Last name', with: 'Genet'
      click_on 'Save and continue'
      expect(page).to have_content('1 defendant has missing or incomplete information: defendant 1')
    end

    it 'shows number of included defendants after incomplete defendants are updated' do
      first(:link_or_button, 'defendant 1').click
      fill_in 'Last name', with: 'Mansfield'
      click_on 'Save and continue'
      first(:link_or_button, 'defendant 1').click
      fill_in 'First name', with: 'Mel'
      click_on 'Save and continue'
      expect(page).to have_content("You've added 3 defendants")
    end
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
