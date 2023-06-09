require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_claim_type_path(claim.id)

    choose 'Non-standard magistrates fee'
    within('.govuk-radios__conditional', text: 'Representation order date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      claim_type: 'non_standard_magistrate',
      rep_order_date: Date.new(2023, 4, 20)
    )
  end
end
