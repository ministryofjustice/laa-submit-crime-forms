require 'rails_helper'

# rubocop:disable RSpec/ExampleLength
RSpec.describe 'User can manage work items', type: :system do
  let(:claim) { create(:claim, :case_type_magistrates, :firm_details, claim_type: ClaimType::NON_STANDARD_MAGISTRATE, import_date: import_date) }
  let(:import_date) { nil }
  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a work item' do
    work_item = claim.work_items.create

    visit edit_nsm_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

    choose 'Advocacy'

    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 1

    within('.govuk-fieldset', text: 'Completion date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'Fee earner initials', with: 'JBJ'

    choose 'No'

    click_on 'Save and continue'

    expect(claim.reload.work_items).to contain_exactly(
      have_attributes(
        work_type: 'advocacy',
        time_spent: 61,
        completed_on: Date.new(2023, 4, 20),
        fee_earner: 'JBJ',
        uplift: 0,
      )
    )
  end

  it 'can add two work items on the trot' do
    visit edit_nsm_steps_work_item_path(id: claim.id, work_item_id: Nsm::StartPage::NEW_RECORD)

    choose 'Advocacy'

    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 1

    within('.govuk-fieldset', text: 'Completion date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'Fee earner initials', with: 'JBJ'

    choose 'Yes'

    click_on 'Save and continue'

    expect(page).to have_current_path(
      edit_nsm_steps_work_item_path(id: claim.id, work_item_id: Nsm::StartPage::NEW_RECORD)
    )

    expect(page).to have_content("You've added 1 work item")

    expect(claim.reload.work_items).to contain_exactly(
      have_attributes(
        work_type: 'advocacy',
        time_spent: 61,
        completed_on: Date.new(2023, 4, 20),
        fee_earner: 'JBJ',
        uplift: 0,
      )
    )
  end

  it 'can add a work item with uplift' do
    claim.update!(reasons_for_claim: [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s])
    work_item = claim.work_items.create

    visit edit_nsm_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

    choose 'Advocacy'

    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 1

    within('.govuk-fieldset', text: 'Completion date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'Fee earner initials', with: 'JBJ'
    check 'Apply an uplift to this work'
    fill_in 'Enter an uplift percentage from 1 to 100', with: 10
    choose 'No'
    click_on 'Save and continue'

    expect(claim.reload.work_items).to contain_exactly(
      have_attributes(
        work_type: 'advocacy',
        time_spent: 61,
        completed_on: Date.new(2023, 4, 20),
        fee_earner: 'JBJ',
        uplift: 10,
      )
    )
  end

  it 'can add additional work items' do
    claim.work_items.create!(
      work_type: 'preparation',
      time_spent: 122,
      completed_on: Date.new(2022, 4, 20),
      fee_earner: 'BJB',
      uplift: 0,
    )

    visit edit_nsm_steps_work_items_path(claim.id)

    choose 'Yes'

    click_on 'Save and continue'

    choose 'Advocacy'

    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 1

    within('.govuk-fieldset', text: 'Completion date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'Fee earner initials', with: 'JBJ'
    choose 'No'

    click_on 'Save and continue'

    expect(claim.reload.work_items).to contain_exactly(
      have_attributes(
        work_type: 'preparation',
        time_spent: 122,
        completed_on: Date.new(2022, 4, 20),
        fee_earner: 'BJB',
        uplift: 0,
      ),
      have_attributes(
        work_type: 'advocacy',
        time_spent: 61,
        completed_on: Date.new(2023, 4, 20),
        fee_earner: 'JBJ',
        uplift: 0,
      ),
    )
  end

  it 'can calculate the result without creating duplicate records' do
    work_item = create(:work_item, claim:)
    visit edit_nsm_steps_work_item_path(claim.id, work_item_id: work_item.id)

    expect { click_on 'Update the calculation' }.not_to change(WorkItem, :count)
  end

  it 'can delete a work_item' do
    work_item = claim.work_items.create(
      work_type: 'advocacy',
      time_spent: 122,
      completed_on: Date.new(2022, 4, 20),
      fee_earner: 'BJB',
      uplift: 0,
    )

    visit edit_nsm_steps_work_items_path(claim.id)

    click_on 'Delete'

    click_on 'Yes, delete it'

    expect(claim.reload.work_items).not_to include(work_item)

    expect(claim.work_items.count).to eq(0)
  end

  it 'can duplicate a work item' do
    claim.work_items.create(
      work_type: 'advocacy',
      time_spent: 122,
      completed_on: Date.new(2022, 4, 20),
      fee_earner: 'BJB',
      uplift: 0,
    )

    visit edit_nsm_steps_work_items_path(claim.id)

    expect(page).to have_content('Advocacy', count: 2) # 1 line item and 1 summary row

    click_on 'Duplicate'

    expect(claim.reload.work_items.count).to eq(1)
    choose 'No'

    click_on 'Save and continue'

    expect(claim.reload.work_items.count).to eq(2)

    expect(page).to have_content('Advocacy', count: 3) # 2 line items and 1 summary row
  end

  it 'forces me to complete work items before continuing' do
    work_item = claim.work_items.create

    visit edit_nsm_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 1

    click_on 'Save and come back later'

    click_on 'Work items'

    expect(page).to have_no_content 'Do you want to add another work item?'

    click_on 'Save and continue'

    expect(page).to have_content 'You cannot save and continue if any work items are incomplete'

    click_on 'Incomplete'

    choose 'Advocacy'

    within('.govuk-fieldset', text: 'Completion date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'Fee earner initials', with: 'JBJ'
    choose 'No'
    click_on 'Save and continue'

    expect(page).to have_content 'Do you want to add another work item?'

    choose 'No'
    click_on 'Save and continue'

    expect(page).to have_no_content 'You cannot save and continue if any work items are incomplete'
  end

  it 'can display incomplete work items' do
    work_item = claim.work_items.create

    visit edit_nsm_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 1

    click_on 'Save and come back later'

    click_on 'Work items'

    expect(page).to have_content '1 work item is incomplete: item 1'
    expect(page).to have_css('.govuk-tag--red', text: 'Incomplete')
  end

  # TODO (CRM457-2388): these tests aren't how they would naturally happen
  # we should update them once the import functionality has been completed
  context 'claim has been imported' do
    let(:import_date) { Date.new(2025, 1, 12) }

    it 'will show the banner saying work items were imported only once' do
      work_item = claim.work_items.create
      work_item.update(created_at: Date.new(2025, 1, 11))

      visit edit_nsm_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

      choose 'Advocacy'

      fill_in 'Hours', with: 1
      fill_in 'Minutes', with: 1

      within('.govuk-fieldset', text: 'Completion date') do
        fill_in 'Day', with: '20'
        fill_in 'Month', with: '4'
        fill_in 'Year', with: '2023'
      end

      fill_in 'Fee earner initials', with: 'JBJ'

      choose 'No'

      click_on 'Save and continue'

      expect(page).to have_css('.govuk-notification-banner__heading', text: 'You imported 1 work item')

      page.refresh

      expect(page).not_to have_css('.govuk-notification-banner__heading', text: 'You imported 1 work item')
    end

    it 'it shows additional content in banner if work items incomplete' do
      work_item = claim.work_items.create
      work_item.update(created_at: Date.new(2025, 1, 11))

      visit edit_nsm_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

      choose 'Advocacy'

      click_on 'Save and come back later'
      click_on 'Work items'

      expect(page).to have_css('.govuk-notification-banner__heading', text: 'You imported 1 work item')
      expect(page).to have_css('.govuk-body', text: '1 work item is incomplete: item 1')
    end
  end
end
# rubocop:enable RSpec/ExampleLength
