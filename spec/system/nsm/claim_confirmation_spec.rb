require 'rails_helper'

RSpec.describe 'User can see an application status', :stub_app_store_search, :stub_oauth_token, type: :system do
  let(:claim) { create(:claim, :complete, :case_type_breach, ufn: '12122025/001', state: :submitted) }

  before do
    stub_nsm_app_store_payload(claim, :submitted, 'LAA-ABC321')
    visit provider_entra_id_omniauth_callback_path
    visit nsm_steps_claim_confirmation_path(claim.id)
  end

  it 'shows LAA reference on the claim confirmation page' do
    expect(page).to have_css('div.govuk-panel__body', text: 'LAA-ABC321')
  end

  it 'can show all claims for a provider when clicking on view your claims button' do
    click_on 'View your claims'
    expect(page).to have_current_path(nsm_applications_path)
    expect(claim.reload).to have_attributes(
      ufn: '12122025/001',
      state: 'submitted',
    )
  end

  it 'can start a new claim when clicking on start a new claim button' do
    expect { click_on 'Start a new claim' }.to change(Claim, :count).by(1)
    new_claim = Claim.order(:created_at).last
    expect(page).to have_content('What are you claiming for')
    expect(new_claim).to have_attributes(
      state: 'draft',
    )
  end
end
