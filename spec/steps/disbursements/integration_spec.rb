require 'rails_helper'

RSpec.describe 'User can manage disbursements', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a simple disbursement' do
    visit edit_steps_letters_calls_path(claim.id)

    # start on the letters and calls page as so we don;t have to manually create the disbursements
    fill_in 'Number of letters', with: 1
    fill_in 'Number of phone calls', with: 2
    expect { click_on 'Save and continue' }.to change(Disbursement, :count).by(1)

    within('.govuk-fieldset', text: 'Date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    choose 'Car'

    click_on 'Save and continue'

    expect(claim.disbursements).to contain_exactly(
      have_attributes(
        disbursement_date: Date.new(2023, 4, 20),
        disbursement_type: 'car',
        other_type: nil,
      )
    )
  end

  it 'can add a other disbursement' do
    disbursement = claim.disbursements.create
    visit edit_steps_disbursement_type_path(claim.id, disbursement_id: disbursement.id)

    within('.govuk-fieldset', text: 'Date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    choose 'Other disbursement type'
    select 'Accountants'

    click_on 'Save and continue'

    expect(claim.disbursements).to contain_exactly(
      have_attributes(
        disbursement_date: Date.new(2023, 4, 20),
        disbursement_type: 'other',
        other_type: 'accountants',
      )
    )
  end
end
