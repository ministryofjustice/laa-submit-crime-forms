require 'system_helper'

RSpec.describe 'Nsm - User can fill in further information', :javascript, :stub_oauth_token, type: :system do
  let(:claim) do
    create(:claim,
           :complete,
           :with_further_information_request,
           :case_type_breach)
  end

  before do
    stub_app_store_payload(claim)
    visit provider_saml_omniauth_callback_path
    visit edit_nsm_steps_further_information_path(claim.id)
  end

  it 'can do green path' do
    fill_in 'Enter the information requested',
            with: 'This is the information'
    click_on 'Save and continue'

    expect(claim.pending_further_information.reload).to have_attributes(
      information_supplied: 'This is the information'
    )
  end
end
