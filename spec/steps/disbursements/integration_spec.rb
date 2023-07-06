require 'rails_helper'

RSpec.describe 'User can manage disbursements', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a simple disbursement' do
    visit edit_steps_letters_calls_path(claim.id)

    # start on the letters and calls page to show flow
    fill_in 'Number of letters', with: 1
    fill_in 'Number of phone calls', with: 2
    expect { click_on 'Save and continue' }.to change(Disbursement, :count).by(0)

    within('.govuk-fieldset', text: 'Date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    choose 'Car'

    click_on 'Save and continue'

    fill_in 'Number of miles', with: 100
    fill_in 'Enter details of this disbursement', with: 'details'
    check 'Apply 20% VAT to this work'

    click_on 'Update the calculation'

    doc = Nokogiri::HTML(page.html)
    values = doc.css('.govuk-table th, .govuk-table td').map(&:text)

    expect(values).to eq(
      [
        'Before VAT', 'After VAT',
        '£45.00', '£54.00'
      ]
    )

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

    fill_in 'Disbursement cost', with: '105.4'
    fill_in 'Enter details of this disbursement', with: 'details'
    check 'Apply 20% VAT to this work'

    click_on 'Update the calculation'

    doc = Nokogiri::HTML(page.html)
    values = doc.css('.govuk-table th, .govuk-table td').map(&:text)

    expect(values).to eq(
      [
        'Before VAT', 'After VAT',
        '£105.40', '£126.48'
      ]
    )

    click_on 'Save and continue'

    expect(claim.disbursements).to contain_exactly(
      have_attributes(
        disbursement_date: Date.new(2023, 4, 20),
        disbursement_type: 'other',
        other_type: 'accountants',
      )
    )
  end

  it 'can delete a disbursement' do
    claim = create(:claim)
    disbursement = create(:disbursement, :valid, claim:)

    visit edit_steps_disbursements_path(claim.id, disbursement_id: disbursement.id)

    click_on 'Delete'

    click_on 'Yes, delete it'

    expect(page).to have_content('The disbursement was deleted')

    expect(Disbursement.find_by(id: disbursement.id)).to be_nil
  end
end
