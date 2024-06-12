require 'system_helper'

RSpec.describe 'Prior authority applications - add case contact', :javascript, type: :system do
  let(:application) { create(:prior_authority_application, :about_request_enabled) }

  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_steps_start_page_path(application)

    expect(page).to have_link 'Reason for prior authority'
    click_on 'Reason for prior authority'
  end

  it 'allows user to submit a reason without attachments' do
    fill_in 'Why is prior authority required?', with: 'important reasons'

    click_on 'Save and continue'

    expect(application.reload).to have_attributes(
      reason_why: 'important reasons'
    )
  end

  it 'allows user to submit a reason with attachments' do
    fill_in 'Why is prior authority required?', with: 'important reasons'
    find('.moj-multi-file-upload__dropzone').drop(file_fixture('test.png'))
    click_on 'Save and continue'

    expect(application.reload).to have_attributes(
      reason_why: 'important reasons'
    )
    expect(application.supporting_documents.first.file_name).to eq 'test.png'
  end

  it 'allows user to upload and delete attachments' do
    expect(page).to have_no_content('test.png')

    find('.moj-multi-file-upload__dropzone').drop(file_fixture('test.png'))

    within('.govuk-table') { expect(page).to have_content(/test.png.*Delete/) }

    click_on 'Delete'

    within('.moj-banner') { expect(page).to have_content('test.png has been deleted') }
    expect(page).to have_no_css('.govuk-table')
  end
end
