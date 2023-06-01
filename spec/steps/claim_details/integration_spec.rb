require 'rails_helper'

RSpec.describe 'User can fill in claim details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_claim_details_path(claim.id)

    fill_in 'Prosecution Evidence', with: 'Prosecution Evidence'
    fill_in 'Defence statement', with: 'Defence Statement'
    fill_in 'Number of Defence witnesses', with: '2'

    find('.govuk-form-group', text: 'Does this bill represent supplemental claim ?').choose 'Yes'
    find('.govuk-form-group',
         text: 'Was any preparation time spent watching or listening to taped evidence ?').choose 'Yes'
    fill_in 'Time spent in hours', with: '10'
    fill_in 'Time spent in minutes', with: '30'
    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      prosecution_evidence: 'Prosecution Evidence',
      defence_statement: 'Defence Statement',
      number_of_witnesses: 2,
      time_spent_hours: 10,
      time_spent_mins: 30
    )
  end
end
