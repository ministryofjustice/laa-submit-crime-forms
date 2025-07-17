require 'system_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe 'Task list', :stub_app_store_search, :stub_oauth_token do
  it 'updates the task list appropriately' do
    visit provider_entra_id_omniauth_callback_path
    click_on "Claim non-standard magistrates' court payments, previously CRM7"
    click_on 'Start a new claim'

    # Claim type
    fill_in 'What is your unique file number (UFN)?', with: '120223/001'
    choose "Non-standard magistrates' court payment"
    within('.govuk-radios__conditional', text: 'Representation order date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end
    click_on 'Save and continue'

    first('.govuk-radios__label').click
    click_on 'Save and continue'

    # Firm in undesignated area
    choose 'No'
    click_on 'Save and continue'

    # Task list:
    expect(page)
      .to have_content('What are you claiming for Completed')
      .and have_content('Firm details Not yet started')
      .and have_content('Defendant details Cannot start yet')

    click_on 'Firm details'

    fill_in 'Firm name', with: 'Lawyers'
    fill_in 'Address line 1', with: 'home'
    fill_in 'Town or city', with: 'hometown'
    fill_in 'Postcode', with: 'AA1 1AA'
    choose 'nsm-steps-firm-details-form-firm-office-attributes-vat-registered-yes-field'
    fill_in 'Solicitor first name', with: 'James'
    fill_in 'Solicitor last name', with: 'Robert'
    fill_in 'Solicitor reference number', with: '2222'

    click_on 'Save and continue'

    # Contact details
    fill_in 'First name', with: 'Jim'
    fill_in 'Last name', with: 'Bob'
    fill_in 'Email address', with: 'jim@bob.com'
    click_on 'Save and continue'

    # Defendant details
    fill_in 'First name', with: 'Jim'
    fill_in 'Last name', with: 'Bob'
    fill_in 'MAAT ID number', with: '1234567'
    click_on 'Save and continue'

    # Defendant summary
    choose 'No'
    click_on 'Save and continue'

    # Case details
    select 'Assault (common)', from: 'Main offence'
    choose 'Summary only'
    within('.govuk-form-group', text: 'Main offence date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    find('.govuk-form-group', text: 'Was there an assigned counsel?').choose 'Yes'
    find('.govuk-form-group', text: 'Was there an unassigned counsel?').choose 'No'
    find('.govuk-form-group', text: 'Was there an instructed agent?').choose 'Yes'
    find('.govuk-form-group',
         text: 'Has the case been remitted from the Crown Court to the magistrates\' court?').choose 'Yes'

    within('.govuk-form-group', text: 'Has the case been remitted from the Crown Court to the magistrates\' court?') do
      fill_in 'Day', with: '02'
      fill_in 'Month', with: '07'
      fill_in 'Year', with: '2023'
    end

    click_on 'Save and continue'

    click_on "Claim a non-standard magistrates' court payment"
    click_on 'Drafts'
    click_on '120223/001'

    # Task list:
    expect(page)
      .to have_content('Firm details Completed')
      .and have_content('Defendant details Completed')
      .and have_content('Case details Completed')

    # Amend firm details - this will prune the old navigation stack
    click_on 'Firm details'
    click_on 'Save and continue'
    click_on "Claim a non-standard magistrates' court payment"
    click_on 'Drafts'
    click_on '120223/001'

    expect(page)
      .to have_content('Firm details Completed')
      .and have_content('Defendant details In progress')
      .and have_content('Case details Cannot start yet')
  end
end
# rubocop:enable RSpec/ExampleLength
