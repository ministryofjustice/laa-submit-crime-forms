require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_letters_calls_path(claim.id)

    fill_in 'Number of letters', with: 1
    fill_in 'Number of phone calls', with: 2

    check 'Apply an uplift to this work'
    fill_in 'For example, from any percentage from 1 to 100', with: 10

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      letters: 1,
      calls: 2,
      letters_calls_uplift: 10,
    )
  end
end
