require 'rails_helper'

RSpec.describe 'User can fill in firm details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_firm_details_path(claim.id)

    fill_in 'Firm name', with: 'Lawyers'
    fill_in 'Firm account number', with: '1111'
    fill_in 'Address line 1', with: 'home'
    fill_in 'Town or city', with: 'hometown'
    fill_in 'Postcode', with: 'AA1 1AA'

    fill_in 'Solicitor full name', with: 'James Robert'
    fill_in 'Solicitor reference number', with: '2222'

    choose 'Yes'

    fill_in 'Full name of alternative contact', with: 'Jim Bob'
    fill_in 'Email address of alternative contact', with: 'jim@bob.com'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      firm_office_id: instance_of(String),
      solicitor_id: instance_of(String),
    )

    expect(claim.firm_office).to have_attributes(
      name: 'Lawyers',
      account_number: '1111',
      address_line_1: 'home',
      town: 'hometown',
      postcode: 'AA1 1AA',
    )

    expect(claim.solicitor).to have_attributes(
      full_name: 'James Robert',
      reference_number: '2222',
      contact_full_name: 'Jim Bob',
      contact_email: 'jim@bob.com',
    )
  end
end
