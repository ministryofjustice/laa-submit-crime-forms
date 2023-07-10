require 'rails_helper'

RSpec.describe 'User can fill in case details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_case_details_path(claim.id)
    select '1 - Assault (common)', from: 'Main offence'
    fill_in 'Day', with: '20'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '2023'

    find('.govuk-form-group', text: 'Was there an assigned counsel?').choose 'Yes'
    find('.govuk-form-group', text: 'Was there an unassigned counsel?').choose 'No'
    find('.govuk-form-group', text: 'Was there an instructed agent?').choose 'Yes'
    find('.govuk-form-group',
         text: 'Has the case been remitted from the Crown Court to the magistrates court?').choose 'No'
    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      main_offence: '1',
      main_offence_date: Date.new(2023, 4, 20),
      assigned_counsel: 'yes',
      unassigned_counsel: 'no',
      agent_instructed: 'yes',
      remitted_to_magistrate: 'no'
    )
  end
end
