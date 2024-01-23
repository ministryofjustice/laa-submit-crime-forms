require 'rails_helper'

RSpec.describe 'User can fill in solicitor declaration', type: :system do
  let(:claim) { create(:claim) }
  let(:app_store_notifier) { instance_double(NotifyAppStore, process: true) }

  before do
    allow(NotifyAppStore).to receive(:new).and_return(app_store_notifier)
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
    expect(NotifyAppStore).to have_received(:new)
    expect(app_store_notifier).to have_received(:process)
  end
end
