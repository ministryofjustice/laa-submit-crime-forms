require 'rails_helper'

RSpec.describe 'User can manage disbursements', type: :system do
  let(:claim) { create(:claim, :firm_details) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a simple disbursement' do
    visit edit_nsm_steps_disbursement_add_path(claim.id)

    choose 'Yes'
    expect { click_on 'Save and continue' }.not_to change(Disbursement, :count)

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
    visit edit_nsm_steps_disbursement_type_path(claim.id, disbursement_id: disbursement.id)

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

    visit edit_nsm_steps_disbursements_path(claim.id, disbursement_id: disbursement.id)

    click_on 'Delete'

    click_on 'Yes, delete it'

    expect(page).to have_content('The disbursement was deleted')

    expect(Disbursement.find_by(id: disbursement.id)).to be_nil
  end

  it 'can skip adding disbursements' do
    visit edit_nsm_steps_disbursement_add_path(claim.id)

    choose 'No'
    expect { click_on 'Save and continue' }.not_to change(Disbursement, :count)

    expect(page).to have_content('Check your payment claim')
  end

  it 'forces me to complete "mileage" disbursements before continuing' do
    visit edit_nsm_steps_disbursement_add_path(claim.id)
    choose 'Yes'

    click_on 'Save and continue'

    within('.govuk-fieldset', text: 'Date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    choose 'Car'

    click_on 'Save and come back later'
    click_on 'Disbursements'

    expect(page).to have_no_content 'Do you want to add another disbursement?'

    click_on 'Save and continue'

    expect(page).to have_content 'You cannot save and continue if any disbursements are incomplete'

    click_on 'Change'
    click_on 'Save and continue'

    fill_in 'Number of miles', with: 100
    fill_in 'Enter details of this disbursement', with: 'details'

    click_on 'Save and continue'

    expect(page).to have_content 'Do you want to add another disbursement?'
    choose 'No'

    click_on 'Save and continue'
    expect(page).to have_no_content 'You cannot save and continue if any disbursements are incomplete'
    expect(page).to have_title 'Check your payment claim'
  end
end
