require 'system_helper'

RSpec.describe 'Prior authority applications - add case contact', :javascript, type: :system do
  let(:application) { create(:prior_authority_application, :about_request_enabled) }

  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_steps_start_page_path(application)

    expect(page).to have_link 'Reason for prior authority'
    click_on 'Reason for prior authority'
  end

  it 'can have a reason without attachments' do
    fill_in 'Why is prior authority required?', with: 'important reasons'

    click_on 'Save and continue'

    expect(application.reload).to have_attributes(
      reason_why: 'important reasons'
    )
  end

  it 'can have a reason with attachments' do
    fill_in 'Why is prior authority required?', with: 'important reasons'
    find('.moj-multi-file-upload__dropzone').drop(Rails.root.join('spec/support/assets/test.png'))
    click_on 'Save and continue'

    expect(application.reload).to have_attributes(
      reason_why: 'important reasons'
    )
    # TODO: Implement verification that file has been uploaded successfully.
  end
end
