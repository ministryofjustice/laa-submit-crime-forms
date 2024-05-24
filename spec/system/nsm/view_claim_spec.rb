require 'rails_helper'

RSpec.describe 'View claim page', type: :system do
  let(:claim) { create(:claim, :firm_details, :letters_calls, work_items:, disbursements:, assessment_comment:) }
  let(:assessment_comment) { 'some random text' }
  let(:work_items) do
    [
      build(:work_item, :attendance_without_counsel, fee_earner: 'AB', time_spent: 90, completed_on: 1.day.ago),
      build(:work_item, :advocacy, time_spent: 104, completed_on: 1.day.ago),
      build(:work_item, :advocacy, time_spent: 86, completed_on: 2.days.ago),
      build(:work_item, :waiting, time_spent: 23, completed_on: 3.days.ago),
      build(:work_item, :travel, time_spent: 23, completed_on: 3.days.ago),
    ]
  end
  let(:disbursements) do
    [
      build(:disbursement, :valid, :car, age: 5, miles: 200),
      build(:disbursement, :valid_other, :dna_testing, age: 3, total_cost_without_vat: 130, prior_authority: 'yes'),
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
        .and have_content('Travel £10.58 £2.12 £12.70')
        .and have_content('Disbursements £327.50 £31.50 £359.00')
        .and have_content('Total £654.50 £96.90 £751.40')
    end
  end

  it 'shows a cost summary on the claim costs page' do
    visit nsm_steps_view_claim_path(claim.id, section: :claimed_costs)

    within('#cost-summary-table') do
      expect(page).to have_content('Item Net cost VAT Total')
        .and have_content('Profit costs £305.84 £61.17 £367.01')
        .and have_content('Waiting £10.58 £2.12 £12.70')
        .and have_content('Travel £10.58 £2.12 £12.70')
        .and have_content('Disbursements £327.50 £31.50 £359.00')
        .and have_content('Total £654.50 £96.90 £751.40')
    end
  end

  # TODO: update this to have adjusted values as well...
  it 'shows an adjusted cost summary on the adjustments page' do
    visit nsm_steps_view_claim_path(claim.id, section: :adjustments)

    within('#cost-summary-table') do
      expect(page).to have_content('Item Net cost VAT Total')
        .and have_content('Profit costs £305.84 £61.17 £367.01')
        .and have_content('Waiting £10.58 £2.12 £12.70')
        .and have_content('Travel £10.58 £2.12 £12.70')
        .and have_content('Disbursements £327.50 £31.50 £359.00')
        .and have_content('Total £654.50 £96.90 £751.40')
    end
  end

  it 'show the work items and summary' do
    visit work_items_nsm_steps_view_claim_path(claim.id)

    # items
    expect(all('table caption, table td, table th').map(&:text)).to eq(
      [
        3.days.ago.strftime('%-d %B %Y'),
        'Item', 'Time claimed', 'Uplift claimed', 'Net cost claimed', 'Action',
        'Travel', '0 hours 23 minutes', '10%', '£10.58', 'View',
        'Waiting', '0 hours 23 minutes', '10%', '£10.58', 'View',

        2.days.ago.strftime('%-d %B %Y'),
        'Item', 'Time claimed', 'Uplift claimed', 'Net cost claimed', 'Action',
        'Advocacy', '1 hour 26 minutes', '0%', '£93.77', 'View',

        1.day.ago.strftime('%-d %B %Y'),
        'Item', 'Time claimed', 'Uplift claimed', 'Net cost claimed', 'Action',
        'Advocacy', '1 hour 44 minutes', '0%', '£113.39', 'View',
        'Attendance without counsel', '1 hour 30 minutes', '0%', '£78.23', 'View'
      ]
    )

    # summary
    find('details').click
    expect(all('details table td, details table th').map(&:text)).to eq(
      [
        'Item', 'Time claimed', 'Net cost claimed',
        'Advocacy', '3 hours 10 minutes', '£207.16',
        'Attendance without counsel', '1 hour 30 minutes', '£78.23',
        'Travel', '0 hours 23 minutes', '£10.58',
        'Waiting', '0 hours 23 minutes', '£10.58',
        'Total', '', '£306.55'
      ]
    )
  end

  context 'when there are more work items than will fit on a page' do
    let(:work_items) do
      build_list(:work_item, 12, :attendance_without_counsel, fee_earner: 'AB', time_spent: 60, completed_on: 1.day.ago)
    end

    it 'shows the sum of all work items in the summary' do
      visit work_items_nsm_steps_view_claim_path(claim.id)

      find('details').click
      expect(all('details table td, details table th').map(&:text)).to eq(
        [
          'Item', 'Time claimed', 'Net cost claimed',
          'Attendance without counsel', '12 hours 0 minutes', '£625.80', 'Total', '', '£625.80'
        ]
      )
    end
  end

  it 'show the letters and calls page' do
    visit letters_and_calls_nsm_steps_view_claim_path(claim.id)

    expect(all('table caption, table td, table th').map(&:text)).to eq(
      [
        'Item', 'Number claimed', 'Uplift claimed', 'Net cost claimed', 'Action',
        'Letters', '2', '0%', '£8.18', 'View',
        'Calls', '3', '0%', '£12.27', 'View'
      ]
    )
  end

  it 'show the disbursements page' do
    visit disbursements_nsm_steps_view_claim_path(claim.id)

    expect(all('table caption, table td, table th').map(&:text)).to eq(
      [
        5.days.ago.strftime('%-d %B %Y'),
        'Item', 'Net cost claimed', 'VAT on claimed', 'Total claimed', 'Action',
        'Car mileage', '£90.00', '£18.00', '£108.00', 'View',

        3.days.ago.strftime('%-d %B %Y'),
        'Item', 'Net cost claimed', 'VAT on claimed', 'Total claimed', 'Action',
        'DNA Testing', '£130.00', '£0.00', '£130.00', 'View',
        'Custom', '£40.00', '£0.00', '£40.00', 'View',

        2.days.ago.strftime('%-d %B %Y'),
        'Item', 'Net cost claimed', 'VAT on claimed', 'Total claimed', 'Action',
        'Car mileage', '£67.50', '£13.50', '£81.00', 'View'
      ]
    )
  end

  it 'show a work item' do
    visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :work_item, item_id: work_items.first.id)

    expect(find('h1').text).to eq('Attendance without counsel')
    expect(all('table caption, table td').map(&:text)).to eq(
      [
        'Your costs',
        'Date',	1.day.ago.strftime('%-d %B %Y'),
        'Fee earner initials', 'AB',
        'Rate applied', '£52.15',
        'Number of hours', '1 hour 30 minutes',
        'Uplift', '0%',
        'Net cost', '£78.23'
      ]
    )
  end

  it 'show letters' do
    visit letters_nsm_steps_view_claim_path(id: claim.id)

    expect(find('h1').text).to eq('Letters')
    expect(all('table caption, table td').map(&:text)).to eq(
      [
        'Your costs',
        'Rate applied', '£4.09',
        'Number of letters', '2',
        'Uplift', '0%',
        'Net cost', '£8.18'
      ]
    )
  end

  it 'show calls' do
    visit calls_nsm_steps_view_claim_path(id: claim.id)

    expect(find('h1').text).to eq('Calls')
    expect(all('table caption, table td').map(&:text)).to eq(
      [
        'Your costs',
        'Rate applied', '£4.09',
        'Number of calls', '3',
        'Uplift', '0%',
        'Net cost', '£12.27'
      ]
    )
  end

  it 'show a disbursement' do
    visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :disbursement, item_id: disbursements.first.id)

    expect(find('h1').text).to eq('Car mileage')
    expect(all('table caption, table td').map(&:text)).to eq(
      [
        'Your costs',
        'Date',	5.days.ago.strftime('%-d %B %Y'),
        'Disbursement type', 'Car mileage',
        'Disbursement description', 'Details',
        'Net cost', '£90.00',
        'VAT', '£18.00',
        'Total cost', '£108.00'
      ]
    )
  end

  it 'show a disbursement - with prior auth' do
    visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :disbursement, item_id: disbursements[1].id)

    expect(find('h1').text).to eq('DNA Testing')
    expect(all('table caption, table td').map(&:text)).to eq(
      [
        'Your costs',
        'Date',	3.days.ago.strftime('%-d %B %Y'),
        'Disbursement type', 'DNA Testing',
        'Disbursement description', 'Details',
        'Prior authority granted?', 'Yes',
        'Net cost', '£130.00',
        'VAT', '£0.00',
        'Total cost', '£130.00'
      ]
    )
  end

  context 'when visiting with an invalid prefix' do
    it 'raises an error' do
      expect { visit work_items_nsm_steps_view_claim_path(claim.id, prefix: 'fake') }.to raise_error('Invalid prefix: fake')
    end
  end

  context 'when adjustments exist' do
    let(:claim) { create(:claim, :firm_details, :adjusted_letters_calls, work_items:, disbursements:, assessment_comment:) }
    let(:work_items) do
      [
        build(:work_item, :attendance_without_counsel, fee_earner: 'AB', time_spent: 90, completed_on: 1.day.ago),
        build(:work_item, :advocacy, :with_adjustment, fee_earner: 'BC', time_spent: 104, completed_on: 1.day.ago),
      ]
    end
    let(:disbursements) do
      [
        build(:disbursement, :valid, :with_adjustment, :car, age: 5, miles: 200),
        build(:disbursement, :valid_other, :dna_testing, age: 3, total_cost_without_vat: 130, prior_authority: 'yes'),
        build(:disbursement, :valid_other, :with_adjustment, :dna_testing, age: 4, total_cost_without_vat: 100,
prior_authority: 'yes'),
      ]
    end

    it 'show the work items and summary' do
      visit work_items_nsm_steps_view_claim_path(claim.id, prefix: 'allowed_')

      # items
      expect(all('table caption, table td, table th').map(&:text)).to eq(
        [
          1.day.ago.strftime('%-d %B %Y'),
          'Item', 'Time claimed', 'Uplift claimed', 'Net cost claimed', 'Time allowed', 'Uplift allowed',
          'Net cost allowed', 'Action',
          'Advocacy', '1 hour 44 minutes', '0%', '£113.39', '0 hours 52 minutes', '0%', '£56.70', 'View'
        ]
      )

      # summary
      find('details').click
      expect(all('details table td, details table th').map(&:text)).to eq(
        [
          'Item', 'Time claimed', 'Net cost claimed', 'Time allowed', 'Net cost allowed',
          'Advocacy', '1 hour 44 minutes', '£113.39', '0 hours 52 minutes', '£56.70',
          'Attendance without counsel', '1 hour 30 minutes', '£78.23', '1 hour 30 minutes', '£78.23',
          'Total', '', '£191.62', '', '£134.92'
        ]
      )
    end

    it 'show the letters and calls page' do
      visit letters_and_calls_nsm_steps_view_claim_path(claim.id, prefix: 'allowed_')

      expect(all('table caption, table td, table th').map(&:text)).to eq(
        [
          'Item', 'Number claimed', 'Uplift claimed', 'Net cost claimed', 'Number allowed', 'Uplift allowed',
          'Net cost allowed', 'Action',
          'Letters', '2', '0%', '£8.18', '1', '0%', '£4.09', 'View',
          'Calls', '3', '0%', '£12.27', '1', '0%', '£4.09', 'View'
        ]
      )
    end

    it 'show the disbursements page' do
      visit disbursements_nsm_steps_view_claim_path(claim.id, prefix: 'allowed_')

      expect(all('table caption, table td, table th').map(&:text)).to eq(
        [
          5.days.ago.strftime('%-d %B %Y'),
          'Item', 'Net cost claimed', 'VAT on claimed', 'Total claimed', 'Net cost allowed', 'VAT on allowed',
          'Total allowed', 'Action',
          'Car mileage', '£90.00', '£18.00', '£108.00', '£0.00', '£0.00', '£0.00', 'View',
          4.days.ago.strftime('%-d %B %Y'),
          'Item', 'Net cost claimed', 'VAT on claimed', 'Total claimed', 'Net cost allowed', 'VAT on allowed',
          'Total allowed', 'Action',
          'DNA Testing', '£100.00', '£0.00', '£100.00', '£0.00', '£0.00', '£0.00', 'View'
        ]
      )
    end

    it 'show a work item' do
      visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :work_item, item_id: work_items.last.id)

      expect(find('h1').text).to eq('Advocacy')
      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Adjusted claim',
          'Number of hours allowed', '0 hours 52 minutes',
          'Uplift allowed', '0%',
          'Net cost allowed', '£56.70',
          'Reason for adjustment', 'WI adjustment',

          'Your costs',
          'Date',	1.day.ago.strftime('%-d %B %Y'),
          'Fee earner initials', 'BC',
          'Rate applied', '£65.42',
          'Number of hours', '1 hour 44 minutes',
          'Uplift', '0%',
          'Net cost', '£113.39'
        ]
      )
    end

    it 'show letters' do
      visit letters_nsm_steps_view_claim_path(id: claim.id)

      expect(find('h1').text).to eq('Letters')
      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Adjusted claim',
          'Number of letters allowed', '1',
          'Uplift allowed', '0%',
          'Net cost allowed', '£4.09',
          'Reason for adjustment', 'Letters adjusted',
          'Your costs',
          'Rate applied', '£4.09',
          'Number of letters', '2',
          'Uplift', '0%',
          'Net cost', '£8.18'
        ]
      )
    end

    it 'show calls' do
      visit calls_nsm_steps_view_claim_path(id: claim.id)

      expect(find('h1').text).to eq('Calls')
      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Adjusted claim',
          'Number of calls allowed', '1',
          'Uplift allowed', '0%',
          'Net cost allowed', '£4.09',
          'Reason for adjustment', 'Calls adjusted',
          'Your costs',
          'Rate applied', '£4.09',
          'Number of calls', '3',
          'Uplift', '0%',
          'Net cost', '£12.27'
        ]
      )
    end

    it 'show a disbursement' do
      visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :disbursement, item_id: disbursements.first.id)

      expect(find('h1').text).to eq('Car mileage')
      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Adjusted claim',
          'Net cost allowed', '£0.00',
          'VAT allowed', '£0.00',
          'Total cost allowed', '£0.00',
          'Reason for adjustment', 'Disbursement Test',
          'Your costs',
          'Date',	5.days.ago.strftime('%-d %B %Y'),
          'Disbursement type', 'Car mileage',
          'Disbursement description', 'Details',
          'Net cost', '£90.00',
          'VAT', '£18.00',
          'Total cost', '£108.00'
        ]
      )
    end
  end
end
