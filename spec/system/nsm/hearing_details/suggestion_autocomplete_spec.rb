require 'system_helper'

RSpec.describe 'Test suggestion autocomplete for court', :javascript, type: :system do
  let(:claim) { create(:claim, :case_details) }

  before do
    visit provider_saml_omniauth_callback_path
    click_link 'Accept analytics cookies'
  end

  it 'can select a value from the autocomplete' do
    visit edit_nsm_steps_case_details_path(id: claim)

    click_on 'Save and continue'

    fill_in 'Which court was the last case hearing heard at?', with: 'Aldershot'

    # Click the first autocomplete suggestion
    find_by_id('nsm-steps-hearing-details-form-court-field__option--0').click

    expect(page).to have_field('Which court was the last case hearing heard at?', with: "Aldershot Magistrates' Court")

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      court: "Aldershot Magistrates' Court"
    )
  end

  it 'can enter a value not found in the autocoplete' do
    visit edit_nsm_steps_case_details_path(id: claim)

    click_on 'Save and continue'

    fill_in 'Which court was the last case hearing heard at?', with: 'Apples'

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      court: 'Apples'
    )
  end

  context 'when revisiting the page' do
    it 'correctly displays values selected from the autocomplete list' do
      claim.update(court: "Aldershot Magistrates' Court")

      visit provider_saml_omniauth_callback_path

      visit edit_nsm_steps_hearing_details_path(id: claim)

      expect(page).to have_field('Which court was the last case hearing heard at?',
                                 with: "Aldershot Magistrates' Court")
    end

    it 'correctly displays custom values' do
      claim.update(court: 'Apples')

      visit provider_saml_omniauth_callback_path

      visit edit_nsm_steps_hearing_details_path(id: claim)

      expect(page).to have_field('Which court was the last case hearing heard at?', with: 'Apples')
    end
  end
end
