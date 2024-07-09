require 'rails_helper'

RSpec.describe 'User can fill in claim details', type: :system do
  let(:claim) { create(:claim, :firm_details) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_nsm_steps_claim_details_path(claim.id)

    fill_in 'Number of pages of prosecution evidence', with: '1'
    fill_in 'Number of pages of defence statements', with: '2'
    fill_in 'Number of witnesses', with: '3'

    find('.govuk-form-group', text: 'Does this bill represent a supplemental claim?').choose 'Yes'
    find('.govuk-form-group',
         text: 'Did you spend time watching or listening to recorded evidence?').choose 'Yes'
    fill_in 'Hours', with: 10
    fill_in 'Minutes', with: 30
    find('.govuk-form-group', text: 'Did you do any work before the representation order date?').choose 'Yes'
    within('.govuk-form-group', text: 'Did you do any work before the representation order date?') do
      fill_in 'Day', with: '26'
      fill_in 'Month', with: '3'
      fill_in 'Year', with: '2023'
    end
    find('.govuk-form-group', text: 'Did you do any further work after the last court hearing?').choose 'No'
    within('.govuk-form-group', text: 'Date work was completed') do
      fill_in 'Day', with: '28'
      fill_in 'Month', with: '3'
      fill_in 'Year', with: '2023'
    end
    find('.govuk-form-group', text: 'Have wasted costs been applied to this case?').choose 'Yes'

    click_on 'Save and continue'
    expect(claim.reload).to have_attributes(
      prosecution_evidence: 1,
      defence_statement: 2,
      number_of_witnesses: 3,
      time_spent: (10 * 60) + 30,
      work_before_date: Date.new(2023, 3, 26),
      work_completed_date: Date.new(2023, 3, 28),
    )
  end
end
