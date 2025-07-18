require 'rails_helper'

RSpec.describe 'User can manage defendants', type: :system do
  let(:claim) { create(:claim, claim_type: ClaimType::NON_STANDARD_MAGISTRATE) }

  before do
    visit provider_entra_id_omniauth_callback_path
  end

  it 'can add a defendant' do
    visit edit_nsm_steps_defendant_details_path(claim.id, defendant_id: Nsm::StartPage::NEW_RECORD)

    within('.govuk-fieldset', text: 'Defendant 1 (lead defendant)') do
      fill_in 'First name', with: 'Jim'
      fill_in 'Last name', with: 'Bob'
      fill_in 'MAAT ID number', with: '1234567'
    end

    click_on 'Save and continue'

    expect(claim.reload.defendants).to contain_exactly(
      have_attributes(
        first_name: 'Jim',
        last_name: 'Bob',
        maat: '1234567',
        position: 1,
        main: true,
      )
    )
  end

  it 'can add an additional defendant' do
    claim.defendants.create(first_name: 'Jim', last_name: 'Bob', maat: '1234567', position: 1, main: true)

    visit edit_nsm_steps_defendant_summary_path(claim.id)
    choose 'Yes'

    click_on 'Save and continue'

    within('.govuk-fieldset', text: 'Defendant 2') do
      fill_in 'First name', with: 'Bob'
      fill_in 'Last name', with: 'Jim'
      fill_in 'MAAT ID number', with: '9876543'
    end

    click_on 'Save and continue'

    expect(claim.reload.defendants).to contain_exactly(
      have_attributes(
        first_name: 'Jim',
        last_name: 'Bob',
        maat: '1234567',
        position: 1,
        main: true,
      ),
      have_attributes(
        first_name: 'Bob',
        last_name: 'Jim',
        maat: '9876543',
        position: 2,
        main: false,
      ),
    )
  end

  it 'can delete a defendant' do
    claim.defendants.create(first_name: 'Jim', last_name: 'Bob', maat: '1234567', position: 1, main: true)
    claim.defendants.create(first_name: 'Bob', last_name: 'Jim', maat: '9876543', position: 2, main: false)

    visit edit_nsm_steps_defendant_summary_path(claim.id)

    find('.govuk-table__row', text: 'Bob Jim').click_on 'Delete'

    click_on 'Yes, delete it'

    expect(claim.reload.defendants).to contain_exactly(
      have_attributes(
        first_name: 'Jim',
        last_name: 'Bob',
        maat: '1234567',
        position: 1,
        main: true,
      )
    )
  end
end
