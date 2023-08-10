require 'rails_helper'

RSpec.describe 'User can manage defendants', type: :system do
  let(:claim) { create(:claim, claim_type: ClaimType::NON_STANDARD_MAGISTRATE) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a defendant' do
    visit edit_steps_defendant_details_path(claim.id, defendant_id: StartPage::NEW_RECORD)

    within('.govuk-fieldset', text: 'Main defendant') do
      fill_in 'Full name', with: 'Jim Bob'
      fill_in 'MAAT ID', with: 'AA1'
    end

    click_on 'Save and continue'

    expect(claim.reload.defendants).to contain_exactly(
      have_attributes(
        full_name: 'Jim Bob',
        maat: 'AA1',
        position: 1,
        main: true,
      )
    )
  end

  it 'can add an additional defendant' do
    claim.defendants.create(full_name: 'Jim Bob', maat: 'AA1', position: 1, main: true)

    visit edit_steps_defendant_summary_path(claim.id)

    choose 'Yes'

    click_on 'Save and continue'

    within('.govuk-fieldset', text: 'Additional defendant') do
      fill_in 'Full name', with: 'Bob Jim'
      fill_in 'MAAT ID', with: 'BB1'
    end

    click_on 'Save and continue'

    expect(claim.reload.defendants).to contain_exactly(
      have_attributes(
        full_name: 'Jim Bob',
        maat: 'AA1',
        position: 1,
        main: true,
      ),
      have_attributes(
        full_name: 'Bob Jim',
        maat: 'BB1',
        position: 2,
        main: false,
      ),
    )
  end

  it 'can delete a defendant' do
    claim.defendants.create(full_name: 'Jim Bob', maat: 'AA1', position: 1, main: true)
    claim.defendants.create(full_name: 'Bob Jim', maat: 'BB1', position: 2, main: false)

    visit edit_steps_defendant_summary_path(claim.id)

    find('.govuk-table__row', text: 'Bob Jim').click_on 'Delete'

    click_on 'Yes, delete it'

    expect(claim.reload.defendants).to contain_exactly(
      have_attributes(
        full_name: 'Jim Bob',
        maat: 'AA1',
        position: 1,
        main: true,
      )
    )
  end
end
