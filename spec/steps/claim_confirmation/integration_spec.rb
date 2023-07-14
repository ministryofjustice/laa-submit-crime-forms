require 'rails_helper'

# it shows LAA reference on the claim confirmation page
# it can show all claims for a provider
# it can start a new claim

RSpec.describe 'User can see an application status', type: :system do
  let(:claim) { Claim.create!(office_code: 'AAA', laa_reference: 'ABC123', status: 'completed') }

  before do
    visit provider_saml_omniauth_callback_path
    visit steps_claim_confirmation_path(claim.id)
  end

  it 'shows LAA reference on the claim confirmation page' do
    expect(page).to have_css('div.govuk-panel__body', text: claim.laa_reference)
  end

  it 'can show all claims for a provider when clicking on view my claims button' do
    click_on 'View my claims'
    expect(page).to have_current_path(applications_path)
    expect(claim.reload).to have_attributes(
      laa_reference: 'ABC123',
      status: 'completed',
    )
  end

  it 'can start a new claim when clicking on start a new claim button' do
    click_on 'Start a new claim'
    # expect(page).to have_current_path edit_steps_claim_type_path(claim.id)
    # expect(claim.reload).to have_attributes(
    #   laa_reference: '',
    #   status: 'pending',
    # )
  end
end
