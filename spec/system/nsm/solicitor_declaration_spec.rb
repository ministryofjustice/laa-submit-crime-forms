require 'rails_helper'

RSpec.describe 'User can fill in solicitor declaration', type: :system do
  let(:claim) { create(:claim) }

  before do
    allow(SubmitToAppStore).to receive(:perform_later)
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_nsm_steps_solicitor_declaration_path(claim.id)

    fill_in 'Full name',
            with: 'John Doe'
    click_on 'Save and submit'

    expect(claim.reload).to have_attributes(
      signatory_name: 'John Doe',
      status: 'submitted'
    )
    expect(SubmitToAppStore).to have_received(:perform_later)
  end
end
