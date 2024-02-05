require 'system_helper'

RSpec.describe 'Test suggestion autocomplete for main_offence', :javascript, type: :system do
  let(:claim) { create(:claim, :main_defendant) }

  it 'can select a value from the autocomplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_nsm_steps_defendant_summary_path(id: claim)

    # TODO: investigate why the browser thinks this field is not visible?
    choose 'No', visible: false
    click_on 'Save and continue'

    offence_field = find_field('Main offence')
    offence_field.fill_in with: 'Wounding or causing'
    page.all('li', text: 'Wounding or causing grievous bodily harm with intent', &:click)
    expect(page).to have_field(
      'Main offence',
      with: 'Wounding or causing grievous bodily harm with intent'
    )

    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      main_offence: 'Wounding or causing grievous bodily harm with intent'
    )
  end

  it 'can enter a value not found in the autocomplete' do
    visit provider_saml_omniauth_callback_path

    visit edit_nsm_steps_defendant_summary_path(id: claim)

    # TODO: investigate why the browser thinks this field is not visible?
    choose 'No', visible: false
    click_on 'Save and continue'

    fill_in 'Main offence', with: 'Apples'
    fill_in 'Day', with: 12
    click_on 'Save and come back later'

    expect(claim.reload).to have_attributes(
      main_offence: 'Apples'
    )
  end

  context 'when revisiting the page' do
    it 'correctly displays values selected from the autocomplete list' do
      claim.update(main_offence: 'Wounding or causing grievous bodily harm with intent')

      visit provider_saml_omniauth_callback_path

      visit edit_nsm_steps_case_details_path(id: claim)

      expect(page).to have_field('Main offence',
                                 with: 'Wounding or causing grievous bodily harm with intent')
    end

    it 'correctly displays custom values' do
      claim.update(main_offence: 'Apples')

      visit provider_saml_omniauth_callback_path

      visit edit_nsm_steps_case_details_path(id: claim)

      expect(page).to have_field('Main offence', with: 'Apples')
    end
  end
end
