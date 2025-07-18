require 'rails_helper'

RSpec.describe 'Contact details', type: :system do
  let(:claim) { create(:claim, :firm_details) }

  before do
    visit provider_entra_id_omniauth_callback_path
  end

  it 'lets me fill in details' do
    visit edit_nsm_steps_contact_details_path(claim.id)

    fill_in 'First name', with: 'Jim'
    fill_in 'Last name', with: 'Bob'
    fill_in 'Email address', with: 'jim@bob.com'

    click_on 'Save and continue'

    expect(claim.reload.solicitor).to have_attributes(
      contact_first_name: 'Jim',
      contact_last_name: 'Bob',
      contact_email: 'jim@bob.com',
    )
  end

  it 'validates' do
    visit edit_nsm_steps_contact_details_path(claim.id)

    click_on 'Save and continue'

    expect(page).to have_content("Enter the contact's first name")
  end
end
