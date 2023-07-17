require 'system_helper'

RSpec.describe 'Test suggestion autocomplete for court', javascript: true, type: :system do
  let(:claim) { create(:claim, :main_defendant) }

  it 'can select a value from the autocomplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_defendant_summary_path(id: claim)

    # TODO: investigate why the browser thinks this field is not visible?
    choose 'No', visible: false
    click_on 'Save and continue'

    fill_in 'Main offence', with: 'Wounding or causing'
    expect(page).to have_field('Main offence', with: 'Wounding or causing grievous bodily harm with intent')

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      main_offence: 'Wounding or causing grievous bodily harm with intent'
    )
  end

  it 'can enter a value not found in the autocoplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_defendant_summary_path(id: claim)

    # TODO: investigate why the browser thinks this field is not visible?
    choose 'No', visible: false
    click_on 'Save and continue'

    fill_in 'Main offence', with: 'Apples'

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      main_offence: 'Apples'
    )
  end

  context 'when revisiting the page' do
    it 'will correctly display values selected from the autocomplete list' do
      claim.update(main_offence: 'Wounding or causing grievous bodily harm with intent')

      visit provider_saml_omniauth_callback_path

      visit edit_steps_case_details_path(id: claim)

      expect(page).to have_field('Main offence',
                                 with: 'Wounding or causing grievous bodily harm with intent')
    end

    it 'will correctly display custom values' do
      claim.update(main_offence: 'Apples')

      visit provider_saml_omniauth_callback_path

      visit edit_steps_case_details_path(id: claim)

      expect(page).to have_field('Main offence', with: 'Apples')
    end
  end
end

require 'system_helper'

RSpec.describe 'Test suggestion autocomplete for court', javascript: true, type: :system do
  let(:claim) { create(:claim, :case_details) }

  it 'can select a value from the autocomplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_case_details_path(id: claim)

    click_on 'Save and continue'

    fill_in 'Which court was the last case hearing heard at?', with: 'Aldershot'
    expect(page).to have_field('Which court was the last case hearing heard at?', with: "Aldershot Magistrates' Court")

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      court: "Aldershot Magistrates' Court"
    )
  end

  it 'can enter a value not found in the autocoplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_steps_case_details_path(id: claim)

    click_on 'Save and continue'

    fill_in 'Which court was the last case hearing heard at?', with: 'Apples'

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

      expect(page).to have_field('Which court was the last case hearing heard at?',
                                 with: "Aldershot Magistrates' Court")
    end

    it 'will correctly display custom values' do
      claim.update(court: 'Apples')

      visit provider_saml_omniauth_callback_path

      visit edit_steps_hearing_details_path(id: claim)

      expect(page).to have_field('Which court was the last case hearing heard at?', with: 'Apples')
    end
  end
end
