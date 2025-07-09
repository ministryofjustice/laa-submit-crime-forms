require 'rails_helper'

RSpec.describe 'User can fill in firm details', type: :system do
  let(:claim) { create(:claim) }

  before do
    visit provider_entra_id_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_nsm_steps_firm_details_path(claim.id)

    fill_in 'Firm name', with: 'Lawyers'
    fill_in 'Address line 1', with: 'home'
    fill_in 'Town or city', with: 'hometown'
    fill_in 'Postcode', with: 'AA1 1AA'

    choose 'nsm-steps-firm-details-form-firm-office-attributes-vat-registered-yes-field'

    fill_in 'Solicitor first name', with: 'James'
    fill_in 'Solicitor last name', with: 'Robert'
    fill_in 'Solicitor reference number', with: '2222'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      firm_office_id: instance_of(String),
      solicitor_id: instance_of(String),
    )

    expect(claim.firm_office).to have_attributes(
      name: 'Lawyers',
      address_line_1: 'home',
      town: 'hometown',
      postcode: 'AA1 1AA',
      vat_registered: 'yes'
    )

    expect(claim.solicitor).to have_attributes(
      first_name: 'James',
      last_name: 'Robert',
      reference_number: '2222',
    )
  end
end
