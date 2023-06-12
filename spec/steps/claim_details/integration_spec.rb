require 'rails_helper'

RSpec.describe 'User can fill in claim details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_claim_details_path(claim.id)

    fill_in 'Prosecution Evidence', with: 'Evidence'
    fill_in 'Defence statement', with: 'Statement'
    fill_in 'Number of Defence witnesses', with: '2'

    find('.govuk-form-group', text: 'Does this bill represent supplemental claim ?').choose 'Yes'
    find('.govuk-form-group',
         text: 'Was any preparation time spent watching or listening to taped evidence ?').choose 'Yes'

    fill_in 'Hours', with: 10
    fill_in 'Minutes', with: 30

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      prosecution_evidence: 'Evidence',
      defence_statement: 'Statement',
      number_of_witnesses: 2,
      time_spent: 10 * 60 + 30,
    )
  end
end
