require 'rails_helper'

RSpec.describe 'User can fill in solicitor declaration', type: :system do
  let(:claim) { create(:claim) }
  let(:claim_submitter) { instance_double(SubmitClaim, process: true) }

  before do
    allow(SubmitClaim).to receive(:new).and_return(claim_submitter)
    visit user_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_solicitor_declaration_path(claim.id)

    fill_in 'Full name',
            with: 'John Doe'
    click_on 'Save and submit'

    expect(claim.reload).to have_attributes(
      signatory_name: 'John Doe',
      status: 'submitted'
    )
    expect(SubmitClaim).to have_received(:new)
    expect(claim_submitter).to have_received(:process)
  end
end
