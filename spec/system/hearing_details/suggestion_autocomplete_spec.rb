require 'system_helper'

RSpec.describe 'Test suggestion autocomplete for court', type: :system, javascript: true do
  let(:claim) { create(:claim, :case_disposal) }

  it 'can select a value from the autocomplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_case_disposal_path(id: claim)

    click_on 'Save and continue'

    fill_in 'Which court was the hearing held at?', with: 'Aldershot'
    expect(page).to have_field('Which court was the hearing held at?', with:  "Aldershot Magistrates' Court")

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      court: "Aldershot Magistrates' Court"
    )
  end

  it 'can enter a value not found in the autocoplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_case_disposal_path(id: claim)

    click_on 'Save and continue'

    fill_in 'Which court was the hearing held at?', with: 'Apples'

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      court: 'Apples'
    )
  end

  context 'when revisiting the page' do
    it 'will correctly display values selected from the autocomplete list' do
      claim.update(court: "Aldershot Magistrates' Court")

      visit provider_saml_omniauth_callback_path

      visit edit_steps_hearing_details_path(id: claim)

      expect(page).to have_field('Which court was the hearing held at?', with: "Aldershot Magistrates' Court")
    end

    it 'will correctly display custom values' do
      claim.update(court: 'Apples')

      visit provider_saml_omniauth_callback_path

      visit edit_steps_hearing_details_path(id: claim)

      expect(page).to have_field('Which court was the hearing held at?', with: 'Apples')
    end
  end
end