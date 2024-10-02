require 'rails_helper'

RSpec.describe 'Nsm - User can fill in further information', :javascript, type: :system do
  let(:claim) do
    create(:claim, :with_further_information_request, work_items: [build(:work_item, :waiting)],
   disbursements: [build(:disbursement, :valid)])
  end

  before do
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
