require 'system_helper'

RSpec.describe 'Nsm - User can fill in further information', :stub_oauth_token, type: :system do
  let(:claim) do
    create(:claim,
           :complete,
           :with_further_information_request,
           :case_type_breach)
  end

  let(:job) { instance_double(SubmitToAppStore, perform: true) }

  before do
    allow(SubmitToAppStore).to receive(:new).and_return(job)
    stub_app_store_payload(claim)
    visit provider_entra_id_omniauth_callback_path
    visit edit_nsm_steps_rfi_solicitor_declaration_path(claim.id)
  end

  it 'can do green path' do
    fill_in 'Full name',
            with: 'John Doe'

    click_on 'Save and submit'
    expect(claim.reload.further_informations.first).to have_attributes(
      signatory_name: 'John Doe'
    )

    expect(job).to have_received(:perform)
  end
end
