require 'rails_helper'

RSpec.describe 'User can manage work items', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA', claim_type: ClaimType::NON_STANDARD_MAGISTRATE) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a work item' do
    work_item = claim.work_items.create

    visit edit_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

    choose 'Advocacy'

    fill_in 'Hours', with: 1
    fill_in 'Minutes', with: 1

    within('.govuk-fieldset', text: 'Completion date') do
      fill_in 'Day', with: '20'
      fill_in 'Month', with: '4'
      fill_in 'Year', with: '2023'
    end

    fill_in 'Fee earner initials', with: 'JBJ'
    click_on 'Save and continue'

    expect(claim.reload.work_items).to contain_exactly(
      have_attributes(
        work_type: 'advocacy',
        time_spent: 61,
        completed_on: Date.new(2023, 4, 20),
        fee_earner: 'JBJ',
        uplift: nil,
      )
    )
  end

  it 'can add a work item with uplift' do
    claim.update!(reasons_for_claim: [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s])
    work_item = claim.work_items.create

    visit edit_steps_work_item_path(id: claim.id, work_item_id: work_item.id)

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
    fill_in 'For example, from any percentage from 1 to 100', with: 10
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
      work_type: 'apples',
      time_spent: 122,
      completed_on: Date.new(2022, 4, 20),
      fee_earner: 'BJB',
      uplift: nil,
    )

    visit edit_steps_work_items_path(claim.id)

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
debugger
    click_on 'Save and continue'
debugger

    expect(claim.reload.work_items).to contain_exactly(
      have_attributes(
        work_type: 'apples',
        time_spent: 122,
        completed_on: Date.new(2022, 4, 20),
        fee_earner: 'BJB',
        uplift: nil,
      ),
      have_attributes(
        work_type: 'advocacy',
        time_spent: 61,
        completed_on: Date.new(2023, 4, 20),
        fee_earner: 'JBJ',
        uplift: nil,
      ),
    )
  end

  it 'can calculate the result without creating duplicate records' do
    visit edit_steps_work_item_path(claim.id, work_item_id: StartPage::NEW_RECORD)

    expect { click_on 'Update the calculation' }.to change(WorkItem, :count).by(1)
    work_item_path = edit_steps_work_item_path(claim.id, work_item_id: WorkItem.last.id)

    expect(page).to have_current_path(work_item_path)

    # Second click just updates the record
    expect { click_on 'Update the calculation' }.not_to change(WorkItem, :count)
  end

  it 'can delete a work_item' do
    work_item = claim.work_items.create(
      work_type: 'advocacy',
      time_spent: 122,
      completed_on: Date.new(2022, 4, 20),
      fee_earner: 'BJB',
      uplift: nil,
    )

    visit edit_steps_work_items_path(claim.id)

    find('.govuk-table__row', text: 'Advocacy').click_on 'Delete'

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
      uplift: nil,
    )

    visit edit_steps_work_items_path(claim.id)

    expect(page).to have_content('Advocacy', count: 1)

    find('.govuk-table__row', text: 'Advocacy').click_on 'Duplicate'

    expect(claim.reload.work_items.count).to eq(2)

    click_on 'Save and continue'

    expect(claim.reload.work_items.count).to eq(2)

    expect(page).to have_content('Advocacy', count: 2)
  end
end
