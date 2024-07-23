require 'rails_helper'

RSpec.describe 'User can see cost breakdowns', type: :system do
  let(:claim) { create(:claim, :firm_details, :letters_calls, work_items:, disbursements:) }
  let(:work_items) do
    [
      build(:work_item, :attendance_without_counsel, time_spent: 90),
      build(:work_item, :advocacy, time_spent: 104),
      build(:work_item, :advocacy, time_spent: 86),
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

  it 'can do green path' do
    visit nsm_steps_cost_summary_path(claim.id)

    expect(page)
      .to have_content('Item Net cost VAT Total')
      .and have_content('Profit costs £305.84 £61.17 £367.01')
      .and have_content('Waiting £0.00 £0.00 £0.00')
      .and have_content('Travel £0.00 £0.00 £0.00')
      .and have_content('Disbursements £227.50 £31.50 £259.00')
      .and have_content('Total £533.34 £92.67 £626.01')
      # Work items
      .and have_content('Without counsel assigned1 hour 30 minutes£78.23') # 52.15 * 90 / 60
      .and have_content('Preparation0 hours 0 minutes£0.00')
      .and have_content('Advocacy3 hours 10 minutes£207.16')
      .and have_content('Total£285.39')
      # Letters and calls
      .and have_content('Letters£8.18') # 4.09 * 2
      .and have_content('Phone calls£12.27') # 4.09 * 3
      .and have_content('Total£20.45')
      # Disbursements
      .and have_content('Car mileage£90.00')
      .and have_content('DNA Testing£30.00')
      .and have_content('Custom£40.00')
      .and have_content('Car mileage£67.50')
      .and have_content('Total£227.50')
  end

  context 'when claimant is not vat registered' do
    before { claim.firm_office.update!(vat_registered: YesNoAnswer::NO) }

    it 'shows summaries without vat (except for explicitly listed disbursements)' do
      visit nsm_steps_cost_summary_path(claim.id)

      expect(page)
        .to have_content('Item Net cost VAT Total')
        .and have_content('Profit costs £305.84 £0.00 £305.84')
        .and have_content('Waiting £0.00 £0.00 £0.00')
        .and have_content('Travel £0.00 £0.00 £0.00')
        .and have_content('Disbursements £227.50 £31.50 £259.00')
        .and have_content('Total £533.34 £31.50 £564.84')
    end
  end
end
