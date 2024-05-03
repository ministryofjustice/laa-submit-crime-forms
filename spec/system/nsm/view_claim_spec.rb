require 'rails_helper'

RSpec.describe 'View claim page', type: :system do
  let(:claim) { create(:claim, :firm_details, :letters_calls, work_items:, disbursements:) }
  let(:work_items) do
    [
      build(:work_item, :attendance_without_counsel, time_spent: 90, completed_on: 1.day.ago),
      build(:work_item, :advocacy, time_spent: 104, completed_on: 1.day.ago),
      build(:work_item, :advocacy, time_spent: 86, completed_on: 2.day.ago),
      build(:work_item, :waiting, time_spent: 23, completed_on: 3.day.ago),
    ]
  end
  let(:disbursements) do
    [
      build(:disbursement, :valid, :car, age: 5, miles: 200),
      build(:disbursement, :valid_other, :dna_testing, age: 4, total_cost_without_vat: 30),
      build(:disbursement, :valid_other, age: 3, other_type: 'Custom', total_cost_without_vat: 40),
      build(:disbursement, :valid, :car, age: 2, miles: 150),
    ]
  end

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'shows a cost summary on the main page' do
    visit nsm_steps_view_claim_path(claim.id)

    within('#cost-summary-table') do
      expect(page).to have_content('Item Net cost VAT Total')
        .and have_content('Profit costs £305.84 £61.17 £367.01')
        .and have_content('Waiting £10.58 £2.12 £12.70')
        .and have_content('Travel £0.00 £0.00 £0.00')
        .and have_content('Disbursements £227.50 £31.50 £259.00')
        .and have_content('Total £543.92 £94.78 £638.70')
    end
  end

  it 'shows a cost summary on the claim costs page' do
    visit nsm_steps_view_claim_path(claim.id, section: :claimed_costs)

    within('#cost-summary-table') do
      expect(page).to have_content('Item Net cost VAT Total')
        .and have_content('Profit costs £305.84 £61.17 £367.01')
        .and have_content('Waiting £10.58 £2.12 £12.70')
        .and have_content('Travel £0.00 £0.00 £0.00')
        .and have_content('Disbursements £227.50 £31.50 £259.00')
        .and have_content('Total £543.92 £94.78 £638.70')
    end
  end

  it 'show the work items on the work items page' do
    visit work_items_nsm_steps_view_claim_path(claim.id)

    # items
    expect(all('table caption, table td, table th').map(&:text)).to eq(
      [
        3.days.ago.strftime('%-d %B %Y'),
        "Item", "Time claimed", "Uplift claimed", "Net cost claimed", "Action",
        "Waiting", "0 hours 23 minutes", "10%", "£10.58", "View",

        2.days.ago.strftime('%-d %B %Y'),
        "Item", "Time claimed", "Uplift claimed", "Net cost claimed", "Action",
        "Advocacy", "1 hour 26 minutes", "0%", "£93.77", "View",

        1.days.ago.strftime('%-d %B %Y'),
        "Item", "Time claimed", "Uplift claimed", "Net cost claimed", "Action",
        "Advocacy", "1 hour 44 minutes", "0%", "£113.39", "View",
        "Attendance without counsel", "1 hour 30 minutes", "0%", "£78.23", "View"
      ]
    )

    # summary
    find('details').click
    expect(all('details table td, details table th').map(&:text)).to eq(
      [
        "Item", "Net cost claimed", "VAT on claimed", "Total claimed",
        "Advocacy", "£207.16", "£0.00", "£207.16",
        "Attendance without counsel", "£78.23", "£0.00", "£78.23",
        "Waiting", "£10.58", "£0.00", "£10.58"
      ]
    )
  end
end
