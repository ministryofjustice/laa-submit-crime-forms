require 'rails_helper'

RSpec.describe 'User can see an application status', type: :system do
  let(:claim) { create(:claim, laa_reference: 'ABC123', status: 'completed') }

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
    expect { click_on 'Start a new claim' }.to change(Claim, :count).by(1)
    new_claim = Claim.order(:created_at).last
    expect(page).to have_content('What are you claiming for')
    expect(new_claim).to have_attributes(
      status: 'pending',
    )
  end
end
