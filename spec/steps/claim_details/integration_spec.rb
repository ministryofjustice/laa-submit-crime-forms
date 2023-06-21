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
    find('.govuk-form-group', text: 'Did you spend time watching or listening to recorded evidence ?').choose 'Yes'
    fill_in 'Hours', with: 10
    fill_in 'Minutes', with: 30
    find('.govuk-form-group', text: 'Did you do any work before the representation order date ?').choose 'Yes'
    within('.govuk-form-group', text: 'Did you do any work before the representation order date ?') do
      fill_in 'Day', with: '26'
      fill_in 'Month', with: '3'
      fill_in 'Year', with: '2023'
    end
    find('.govuk-form-group', text: 'Did you do any further work after the last court hearing date?').choose 'No'

    click_on 'Save and continue'
    expect(claim.reload).to have_attributes(
      prosecution_evidence: 'Evidence',
      defence_statement: 'Statement',
      number_of_witnesses: 2,
      time_spent: (10 * 60) + 30,
      work_before_date: Date.new(2023, 3, 26),
    )
  end
end
