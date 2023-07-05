require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    claim.update!(reasons_for_claim: [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s])

    visit edit_steps_letters_calls_path(claim.id)

    fill_in 'Number of letters', with: 1
    fill_in 'Number of phone calls', with: 2

    within '[data-cy=apply-letters-uplift]' do
      check 'Apply an uplift to this work'
      fill_in 'For example, from any percentage from 1 to 100', with: 10
    end

    within '[data-cy=apply-calls-uplift]' do
      check 'Apply an uplift to this work'
      fill_in 'For example, from any percentage from 1 to 100', with: 20
    end

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      letters: 1,
      calls: 2,
      letters_uplift: 10,
      calls_uplift: 20,
    )
  end
end
