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

    fill_in 'Solicitor first name', with: 'James'
    fill_in 'Solicitor surname', with: 'Robert'
    fill_in 'Solicitor reference number', with: '2222'

    fill_in 'Contact full name', with: 'Jim Bob'
    fill_in 'Telephone number', with: '07111111111'

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
      first_name: 'James',
      surname: 'Robert',
      reference_number: '2222',
      contact_full_name: 'Jim Bob',
      telephone_number: '07111111111',
    )
  end
end
