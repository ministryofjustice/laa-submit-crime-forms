require 'rails_helper'

RSpec.describe 'User can manage work items', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA', claim_type: ClaimType::NON_STANDARD_MAGISTRATE) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a work item' do
    visit edit_steps_work_item_path(claim.id)

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

    visit edit_steps_work_item_path(claim.id)

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
    claim.work_items.create(
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

    click_on 'Save and continue'

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

    # it redirects to the new work item page when the last record is
    # deleted - this create a new work item record. :)
    expect(claim.work_items.count).to eq(1)
  end
end
