require 'rails_helper'

RSpec.describe 'Youth court claim additional fee', type: :system do
  let(:claim) { create(:claim, :complete) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'Lets me select an option' do
    visit edit_nsm_steps_youth_court_claim_additional_fee_path(claim.id)

    choose 'Yes'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      youth_court_fee_claimed: 'yes'
    )
  end

  it 'validates' do
    visit edit_nsm_steps_youth_court_claim_additional_fee_path(claim.id)

    click_on 'Save and continue'

    expect(page).to have_content("Select the yes if you wish to claim the youth court addition fee")
  end
end
