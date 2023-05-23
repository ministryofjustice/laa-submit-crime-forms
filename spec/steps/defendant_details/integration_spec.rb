require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA', claim_type: ClaimType::NON_STANDARD_MAGISTRATE) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_defendant_details_path(claim.id)

    within('.govuk-fieldset', text: 'Main defendant') do
      fill_in 'Full name', with: 'Jim Bob'
      fill_in 'MAAT ID', with: 'AA1'
    end
    click_on 'Add another defendant'

    within('.govuk-fieldset', text: 'Additional defendant 1') do
      fill_in 'Full name', with: 'Jack Bob'
      fill_in 'MAAT ID', with: 'BB1'
    end

    click_on 'Save and continue'

    expect(claim.reload.defendants).to match_array([
      have_attributes(
        full_name: 'Jim Bob',
        maat: 'AA1',
        position: 1,
        main: true,
      ),
      have_attributes(
        full_name: 'Jack Bob',
        maat: 'BB1',
        position: 2,
        main: false,
      )
    ])
  end
end
