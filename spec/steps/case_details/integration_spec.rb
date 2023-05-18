require 'rails_helper'

RSpec.describe 'User can fill in case details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_case_details_path(claim.id)

    fill_in 'Your Unique File Number', with: 'UFN123'
    fill_in 'Main offence', with: 'Murder'
    fill_in 'Day', with: '20'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '2023'

    choose ('steps-case-details-form-assigned-counsel-yes-field')
    choose ('steps-case-details-form-unassigned-counsel-no-field')
    choose ('steps-case-details-form-agent-instructed-yes-field')
    choose ('steps-case-details-form-remitted-to-magistrate-no-field')

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      ufn: 'UFN123',
      main_offence: 'Murder',
      main_offence_date: Date.new(2023, 4, 20),
      assigned_counsel: 'yes',
      unassigned_counsel: 'no',
      agent_instructed: 'yes',
      remitted_to_magistrate: 'no'
    )
  end
end
