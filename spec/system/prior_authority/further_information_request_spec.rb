require 'system_helper'

RSpec.describe 'provider responds to further information request', :javascript, :stub_oauth_token, type: :system do
  let(:application) { create(:prior_authority_application, :full, :with_further_information_request) }

  before do
    # Fudge the data to make it looks like something the app store would return
    data = SubmitToAppStore::PayloadBuilder.call(application).merge(last_updated_at: 1.hour.ago)
    data[:application][:resubmission_deadline] = 1.day.from_now
    stub_request(:get, "https://app-store.example.com/v1/application/#{application.id}").to_return(
      status: 200,
      body: data.to_json
    )
    visit provider_entra_id_omniauth_callback_path
    visit edit_prior_authority_steps_further_information_path(application)
  end

  it 'displays requested information' do
    expect(page).to have_title('Further information request')
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

    expect(page).to have_current_path edit_prior_authority_steps_check_answers_path(application)
  end

  it 'allows user to submit further information with attachments' do
    expect(page).to have_no_content('test.png')
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

    within('.govuk-table') { expect(page).to have_content(/test.png.*Delete/) }

    click_on 'Delete'

    within('.moj-alert') { expect(page).to have_content('test.png has been deleted') }
    expect(page).to have_no_css('.govuk-table')
  end

  it 'takes me back to application details' do
    click_on 'Back'
    expect(page).to have_current_path prior_authority_application_path(application)
  end

  it 'can be navigated from check answers' do
    visit edit_prior_authority_steps_check_answers_path(application)
    click_on 'Change' # There should only be one of these on the page
    expect(page).to have_current_path(
      edit_prior_authority_steps_further_information_path(application, return_to: :check_answers)
    )
    click_on 'Back'
    expect(page).to have_current_path edit_prior_authority_steps_check_answers_path(application)

    click_on 'Back'
    expect(page).to have_current_path prior_authority_application_path(application)
  end
end
