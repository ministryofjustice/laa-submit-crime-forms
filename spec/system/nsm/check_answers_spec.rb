require 'rails_helper'

RSpec.describe 'Check answers page', type: :system do
  let(:claim) { create(:claim, :firm_details, :letters_calls, work_items:, disbursements:) }
  let(:work_items) do
    [
      build(:work_item, :attendance_without_counsel, time_spent: 90),
      build(:work_item, :advocacy, time_spent: 104),
      build(:work_item, :advocacy, time_spent: 86),
      build(:work_item, :waiting, time_spent: 23),
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
    visit nsm_steps_check_answers_path(claim.id)

    expect(all('#cost-summary-table table td, #cost-summary-table table th').map(&:text)).to eq(
      [
        'Item', 'Net cost', 'VAT', 'Total',
        'Profit costs', '£305.84', '£61.17', '£367.01',
        'Disbursements', '£227.50', '£31.50', '£259.00',
        'Travel', '£0.00', '£0.00', '£0.00',
        'Waiting', '£10.58', '£2.12', '£12.70',
        'Total',
        'Sum of net cost claimed: £543.92',
        'Sum of VAT on claimed: £94.78',
        'Sum of net cost and VAT on claimed: £638.70'
      ]
    )
  end
end
