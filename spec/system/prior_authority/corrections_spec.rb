require 'system_helper'

RSpec.describe 'Prior authority applications - provider responds to correction request', :javascript, :stub_oauth_token,
               type: :system do
  let(:application) do
    create(:prior_authority_application,
           :with_complete_prison_law,
           :sent_back_for_incorrect_info,
           next_hearing: true,
           next_hearing_date: '2024-3-02')
  end

  before do
    # Fudge the data to make it looks like something the app store would return
    application.incorrect_informations.first.update(sections_changed: [])
    data = SubmitToAppStore::PayloadBuilder.call(application).merge(last_updated_at: 1.hour.ago)
    data[:application][:resubmission_deadline] = 1.day.from_now
    stub_request(:get, "https://app-store.example.com/v1/application/#{application.id}").to_return(
      status: 200,
      body: data.to_json
    )
    visit provider_entra_id_omniauth_callback_path
    visit prior_authority_application_path(application)
  end

  it 'displays requested information' do
    expect(page).to have_content('Please update the case details')
    expect(page).to have_content('Update needed')
  end

  it 'allows user to make corrections' do
    click_on 'Update application'
    within('.govuk-summary-card', text: 'Case and hearing details') { click_on 'Change' }
    choose 'No'
    click_on 'Save and continue'

    expect(page).to have_current_path edit_prior_authority_steps_check_answers_path(application)
  end
end
