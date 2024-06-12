require 'system_helper'

RSpec.describe 'Prior authority applications - provider responds to further information request',
               :javascript, type: :system do
  let(:application) { create(:prior_authority_application, :with_further_information_request) }

  before do
    visit provider_saml_omniauth_callback_path
    visit edit_prior_authority_steps_further_information_path(application)
  end

  it 'displays requested information' do
    expect(page).to have_title('Further information requested')
    expect(page).to have_content('Your application needs the following further information to proceed')
    expect(page).to have_content('please provide further evidence')
  end

  it 'allows user to submit further information without attachments' do
    fill_in 'Enter the information requested', with: 'here is the information requested'

    click_on 'Save and continue'

    expect(application.reload.further_informations.first)
      .to have_attributes(
        information_supplied: 'here is the information requested'
      )
  end

  it 'allows user to submit further information with attachments' do
    fill_in 'Enter the information requested', with: 'here is the information requested'
    find('.moj-multi-file-upload__dropzone').drop(file_fixture('test.png'))
    click_on 'Save and continue'

    expect(application.reload.further_informations.first)
      .to have_attributes(
        information_supplied: 'here is the information requested'
      )

    expect(application.further_informations.first.supporting_documents.first.file_name).to eq 'test.png'
  end

  it 'allows user to upload and delete attachments' do
    expect(page).to have_no_content('test.png')

    find('.moj-multi-file-upload__dropzone').drop(file_fixture('test.png'))

    within('.govuk-table') { expect(page).to have_content(/test.png\s+100%\s+Delete/) }

    click_on 'Delete'

    within('.moj-banner') { expect(page).to have_content('test.png has been deleted') }
    expect(page).to have_no_css('.govuk-table')
  end
end
