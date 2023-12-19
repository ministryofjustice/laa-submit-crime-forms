require 'rails_helper'

RSpec.describe 'Letters and Calls' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:submitted_claim) }

  before do
    sign_in user
    visit '/assess'
    click_link 'Accept analytics cookies'
  end

  # rubocop:disable RSpec/ExampleLength
  it 'can adjust a letter record' do
    visit assess_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£83.30' \
        'Change'
      )
      click_link 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of letters', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_button 'Save changes'

    # need to access page directly as not JS enabled
    visit assess_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '22' \
        '95%' \
        '£83.30' \
        '0%' \
        '£78.32' \
        'Change'
      )
    end
  end

  it 'can adjust a call record' do
    visit assess_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£17.09' \
        'Change'
      )
      click_link 'Change'
    end

    choose 'Yes, remove uplift'
    fill_in 'Change number of calls', with: '22'
    fill_in 'Explain your decision', with: 'Testing'

    click_button 'Save changes'

    # need to access page directly as not JS enabled
    visit assess_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '22' \
        '20%' \
        '£17.09' \
        '0%' \
        '£78.32' \
        'Change'
      )
    end
  end

  it 'can remove all uplift' do
    visit assess_claim_letters_and_calls_path(claim)

    click_link 'Remove uplifts for all items'

    fill_in 'Explain your decision', with: 'Testing'

    click_button 'Yes, remove all uplift'

    # need to access page directly as not JS enabled
    visit assess_claim_letters_and_calls_path(claim)

    within('.govuk-table__row', text: 'Letters') do
      expect(page).to have_content(
        'Letters' \
        '12' \
        '95%' \
        '£83.30' \
        '0%' \
        '£42.72' \
        'Change'
      )
    end
    within('.govuk-table__row', text: 'Calls') do
      expect(page).to have_content(
        'Calls' \
        '4' \
        '20%' \
        '£17.09' \
        '0%' \
        '£14.24' \
        'Change'
      )
    end

    expect(page).not_to have_content('Remove uplifts for all items')
  end
  # rubocop:enable RSpec/ExampleLength
end
