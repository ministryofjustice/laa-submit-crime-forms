require 'rails_helper'

RSpec.describe 'Disbursements' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:submitted_claim) }
  let(:disbursement_form_error_message) { 'activemodel.errors.models.assess/disbursements_form.attributes' }

  before { sign_in user }

  # rubocop:disable RSpec/ExampleLength
  it 'can refuse disbursement item' do
    visit assess_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        'Apples' \
        '£100.00' \
        '0%' \
        'Change'
      )
    end
    click_link 'Change'
    choose 'Yes'
    fill_in 'Explain your decision', with: 'Testing'
    click_button 'Save changes'
    visit assess_claim_disbursements_path(claim)

    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        'Apples' \
        '£100.00' \
        '0%' \
        '£0.00' \
        'Change'
      )
    end
    expect(page).to have_css('.govuk-heading-l', text: '£0.00')
  end
  # rubocop:enable RSpec/ExampleLength

  it 'shows error if no changes made to an item' do
    visit assess_claim_disbursements_path(claim)
    within('.govuk-table__row', text: 'Apples') do
      expect(page).to have_content(
        'Apples' \
        '£100.00' \
        '0%' \
        'Change'
      )
    end
    click_link 'Change'
    choose 'No'
    click_button 'Save changes'
    expect(page).to have_css('.govuk-error-summary__body',
                             text: I18n.t("#{disbursement_form_error_message}.base.no_change"))
  end
end
