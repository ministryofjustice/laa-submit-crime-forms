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

  it 'can add another disbursement' do
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

    click_on 'Car mileage'
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

  context 'when disbursements exist' do
    before { visit edit_nsm_steps_disbursements_path(claim.id) }

    let(:claim) { create(:claim, :firm_details, disbursements:) }

    let(:disbursements) do
      [
        build(:disbursement, :valid_other, :dna_testing, age: 3, total_cost_without_vat: 129),
        build(:disbursement, :valid, :bike, age: 5, miles: 200),
        build(:disbursement, :valid, :car, age: 5, miles: 200),
        build(:disbursement, :valid_other, :dna_testing, age: 4, total_cost_without_vat: 150,),
      ]
    end

    it 'lists all disbursements' do
      expect(page).to have_selector('h1', text: "You've added 4 disbursements")

      expect(all('table caption, table td, table th').map(&:text)).to eq(
        [
          'Claimed disbursements',
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete'
        ]
      )
    end

    it 'allows me to sort disbursements by Cost type' do
      click_on 'Cost type'

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete'
        ]
      )

      click_on 'Cost type'

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete'
        ]
      )
    end

    it 'allows me to sort disbursements by Date' do
      click_on 'Date'

      # NOTE: sorting in reverse as dat is the default ordering
      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete'
        ]
      )

      click_on 'Date'

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete'
        ]
      )
    end

    it 'allows me to sort adjusted work items by Net cost' do
      click_on 'Net cost'

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete'
        ]
      )

      click_on 'Net cost'

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete'
        ]
      )
    end

    it 'allows me to sort adjusted work items by Total cost' do
      click_on 'Total cost'

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete'
        ]
      )

      click_on 'Total cost'

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '3', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '4', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete',
          '2', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete'
        ]
      )
    end

    it 'allows me to duplicate a disbursement' do
      expect(page).to have_selector('h1', text: "You've added 4 disbursements")

      within('table tr', text: 'Bike mileage') do
        click_on 'Duplicate'
      end

      expect(page)
        .to have_title('Disbursement type')
        .and have_selector('.govuk-notification-banner', text: 'Disbursement successfully duplicated')

      click_on 'Save and continue'

      expect(page).to have_title('Disbursement cost')

      fill_in 'Number of miles', with: '100.0'
      click_on 'Save and continue'

      expect(page)
        .to have_title('Disbursements')
        .and have_selector('h1', text: "You've added 5 disbursements")

      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
          '2', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£25.00', '£30.00', 'Duplicate Delete',
          '3', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£108.00', 'Duplicate Delete',
          '4', 'DNA Testing', 4.days.ago.to_fs(:short_stamp), '£150.00', '£150.00', 'Duplicate Delete',
          '5', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£129.00', '£129.00', 'Duplicate Delete'
        ]
      )
    end
  end

  context 'when incomplete disbursements exist' do
    before { visit edit_nsm_steps_disbursements_path(claim.id) }

    let(:claim) { create(:claim, :firm_details, disbursements:) }

    let(:disbursements) do
      [
        build(:disbursement, :valid, :bike, age: 5, miles: 200),
        build(:disbursement, :bike, disbursement_date: nil, disbursement_type: nil, total_cost_without_vat: nil),
      ]
    end

    it 'lists incomplete disbursements' do
      expect(page).to have_selector('h1', text: "You've added 2 disbursement")

      expect(all('table caption, table td, table th').map(&:text)).to eq(
        [
          'Claimed disbursements',
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Incomplete', 'Incomplete', 'Incomplete', 'Incomplete', 'Duplicate Delete',
          '2', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
        ]
      )
    end

    it 'allows me to sort by any header without error' do
      click_on 'Item'
      expect(page).to have_selector('h1', text: "You've added 2 disbursement")

      click_on 'Cost type'
      expect(page).to have_selector('h1', text: "You've added 2 disbursement")

      click_on 'Date'
      expect(page).to have_selector('h1', text: "You've added 2 disbursement")

      click_on 'Net cost'
      expect(page).to have_selector('h1', text: "You've added 2 disbursement")

      click_on 'Total cost'
      expect(page).to have_selector('h1', text: "You've added 2 disbursement")
    end

    it 'errors render incompletes in expected order' do
      expect(page).to have_selector('h1', text: "You've added 2 disbursement")

      click_on 'Save and continue'

      expect(page).to have_selector('.govuk-error-summary',
                                    text: 'You cannot save and continue if any disbursements are incomplete')

      expect(all('table caption, table td, table th').map(&:text)).to eq(
        [
          'Claimed disbursements',
          'Item', 'Cost type', 'Date', 'Net cost', 'Total cost', 'Action',
          '1', 'Incomplete', 'Incomplete', 'Incomplete', 'Incomplete', 'Duplicate Delete',
          '2', 'Bike mileage', 5.days.ago.to_fs(:short_stamp), '£50.00', '£60.00', 'Duplicate Delete',
        ]
      )
    end
  end

  it 'validates the initial question' do
    visit edit_nsm_steps_disbursement_add_path(claim.id)

    click_on 'Save and continue'

    expect(page).to have_content 'Select yes if you need to claim a disbursement'
  end
end
