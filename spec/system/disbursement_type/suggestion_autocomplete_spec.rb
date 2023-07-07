require 'system_helper'

RSpec.describe 'Test suggestion autocomplete for court', type: :system, javascript: true do
  let(:claim) { create(:claim, :letters_calls) }
  let(:other_type_field) { 'steps-disbursement-type-form-other-type-field' }

  it 'can select a value from the autocomplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_letters_calls_path(id: claim)

    click_on 'Save and continue'
debugger
    choose 'Other disbursement type'
    fill_in other_type_field, with: 'Accident'

    expect(page).to have_field(other_type_field, with: "Accident & Emergency Report")

    click_on 'Save and come back later'

    expect(claim.disbursements.first).to have_attributes(
      other_type: "Accident & Emergency Report"
    )
  end

  it 'can enter a value not found in the autocoplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_letters_calls_path(id: claim)

    click_on 'Save and continue'

    choose 'Other disbursement type'
    fill_in other_type_field, with: 'Apples'

    click_on 'Save and come back later'

    expect(claim.disbursements.first).to have_attributes(
      other_type: 'Apples'
    )
  end

  context 'when revisiting the page' do
    let(:disbursement) { create(:disbursement, claim: claim, disbursement_type: DisbursementTypes::OTHER) }

    it 'will correctly display values selected from the autocomplete list' do
      disbursement.update(other_type: 'Accident & Emergency Report')

      visit provider_saml_omniauth_callback_path

      visit edit_steps_disbursement_type_path(id: claim, disbursement_id: disbursement.id)

      expect(page).to have_field(other_type_field, with: 'Accident & Emergency Report')
    end

    it 'will correctly display custom values' do
      claim.update(court: 'Apples')

      visit provider_saml_omniauth_callback_path

      visit edit_steps_disbursement_type_path(id: claim, disbursement_id: disbursement.id)

      expect(page).to have_field(other_type_field, with: 'Apples')
    end
  end
end