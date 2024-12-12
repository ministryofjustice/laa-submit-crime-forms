require 'system_helper'

RSpec.describe 'View claim page', :stub_oauth_token, type: :system do
  let(:claim) do
    create(:claim, :case_type_magistrates, :complete, :letters_calls,
           firm_office: build(:firm_office, :full, :valid), reasons_for_claim: ['extradition'],
           work_items: work_items, office_in_undesignated_area: true, court_in_undesignated_area: true,
           assigned_counsel: 'yes', disbursements: disbursements, youth_court: youth_court,
           include_youth_court_fee: include_youth_court_fee, plea_category: plea_category, rep_order_date: rep_order_date,
           youth_court_fee_adjustment_comment: youth_court_fee_adjustment_comment,
           allowed_youth_court_fee: allowed_youth_court_fee, assessment_comment: assessment_comment, state: state)
  end

  let(:work_items) do
    [
      build(:work_item,
            :attendance_without_counsel,
            fee_earner: 'AB',
            time_spent: 90,
            completed_on: 1.day.ago,
            allowed_work_type: :attendance_with_counsel),
      build(:work_item, :valid, :advocacy, :with_adjustment, time_spent: 104, completed_on: 1.day.ago, fee_earner: 'AA'),
      build(:work_item, :valid, :advocacy, time_spent: 86, completed_on: 2.days.ago, fee_earner: 'BB'),
      build(:work_item, :valid, :waiting, time_spent: 23, completed_on: 3.days.ago),
      build(:work_item, :valid, :travel, :with_adjustment, time_spent: 23, completed_on: 3.days.ago),
    ]
  end

  let(:disbursements) do
    [
      build(:disbursement, :valid, :car, age: 5, miles: 200),
      build(:disbursement, :valid_other, :dna_testing, age: 3, total_cost_without_vat: 130),
      build(:disbursement, :valid_other, :with_adjustment, age: 3, other_type: 'Custom', total_cost_without_vat: 40),
      build(:disbursement, :valid, :car, :with_adjustment, allowed_apply_vat: 'false', age: 2, miles: 150),
    ]
  end

  let(:include_youth_court_fee) { false }
  let(:plea_category) { 'category_1a' }
  let(:rep_order_date) { Date.new(2024, 12, 6) }
  let(:youth_court) { 'yes' }
  let(:youth_court_fee_adjustment_comment) { nil }
  let(:allowed_youth_court_fee) { nil }
  let(:assessment_comment) { nil }
  let(:state) { :submitted }

  before do
    visit provider_saml_omniauth_callback_path
    stub_app_store_payload(claim)
  end

  it 'shows a cost summary table on the claimed costs page' do
    visit claimed_costs_work_items_nsm_steps_view_claim_path(claim.id)

    expect(page).to have_no_selector('.govuk-summary-card', text: 'Cost summary')
    expect(page).to have_selector('.govuk-table__caption', text: 'Cost summary')

    expect(all('#cost-summary-table table td, #cost-summary-table table th').map(&:text)).to eq(
      [
        'Item', 'Net cost', 'VAT', 'Total',
        'Profit costs', '£305.84', '£61.17', '£367.01',
        'Disbursements', '£327.50', '£31.50', '£359.00',
        'Travel', '£10.58', '£2.12', '£12.70',
        'Waiting', '£10.58', '£2.12', '£12.70',
        'Total',
        'Sum of net cost claimed: £654.50',
        'Sum of VAT on claimed: £96.90',
        'Sum of net cost and VAT on claimed: £751.40'
      ]
    )
  end

  it 'show the work items and summary' do
    visit claimed_costs_work_items_nsm_steps_view_claim_path(claim.id)

    # items
    within('table', text: 'Claimed work items') do
      expect(all('caption, td, th').map(&:text)).to eq(
        [
          'Claimed work items',
          'Item', 'Cost type', 'Date', 'Fee earner', 'Time claimed', 'Uplift claimed', 'Net cost claimed',
          '1', 'Travel', 3.days.ago.to_fs(:short_stamp), 'TT', '0 hours:23 minutes', '10%', '£10.58',
          '2', 'Waiting', 3.days.ago.to_fs(:short_stamp), 'TT', '0 hours:23 minutes', '10%', '£10.58',
          '3', 'Advocacy', 2.days.ago.to_fs(:short_stamp), 'BB', '1 hour:26 minutes', '0%', '£93.77',
          '4', 'Advocacy', 1.day.ago.to_fs(:short_stamp), 'AA', '1 hour:44 minutes', '0%', '£113.39',
          '5', 'Attendance without counsel', 1.day.ago.to_fs(:short_stamp), 'AB', '1 hour:30 minutes', '0%', '£78.23'
        ]
      )
    end

    # summary
    find('details').click
    expect(page).to have_selector('caption.govuk-visually-hidden', text: 'Summary of work items')

    expect(all('details table td, details table th').map(&:text)).to eq(
      [
        'Item', 'Time claimed', 'Net cost claimed',
        'Travel', '0 hours:23 minutes', '£10.58',
        'Waiting', '0 hours:23 minutes', '£10.58',
        'Attendance with counsel', '0 hours:00 minutes', '£0.00',
        'Attendance without counsel', '1 hour:30 minutes', '£78.23',
        'Preparation', '0 hours:00 minutes', '£0.00',
        'Advocacy', '3 hours:10 minutes', '£207.16',
        'Total', '', 'Sum of net cost claimed: £306.55'
      ]
    )
  end

  context 'when claim is not yet submitted' do
    let(:claim) { create(:claim, :complete, :case_type_breach, state: 'draft') }

    it 'redirects me' do
      visit nsm_steps_view_claim_path(claim)
      expect(page).to have_current_path nsm_steps_start_page_path(claim)
    end
  end

  context 'when there are more work items than will fit on a page' do
    let(:work_items) do
      build_list(:work_item, 12, :attendance_without_counsel, fee_earner: 'AB', time_spent: 60, completed_on: 1.day.ago)
    end

    it 'shows the sum of all work items in the summary' do
      visit claimed_costs_work_items_nsm_steps_view_claim_path(claim.id)

      find('details').click
      expect(all('details table td, details table th').map(&:text).join).to include(
        'Attendance without counsel12 hours:00 minutes£625.80',
        'TotalSum of net cost claimed: £625.80'
      )
    end
  end

  it 'show the letters and calls page' do
    visit claimed_costs_letters_and_calls_nsm_steps_view_claim_path(claim.id)

    expect(all('table td, table th').map(&:text)).to eq(
      [
        'Item', 'Net cost', 'VAT', 'Total',
        'Profit costs', '£305.84', '£61.17', '£367.01',
        'Disbursements', '£327.50', '£31.50', '£359.00',
        'Travel', '£10.58', '£2.12', '£12.70',
        'Waiting', '£10.58', '£2.12', '£12.70',
        'Total',
        'Sum of net cost claimed: £654.50',
        'Sum of VAT on claimed: £96.90',
        'Sum of net cost and VAT on claimed: £751.40',
        'Cost type', 'Number claimed', 'Uplift claimed', 'Net cost claimed',
        'Letters', '2', '0%', '£8.18',
        'Calls', '3', '0%', '£12.27'
      ]
    )
  end

  context 'when there is an additional fee claimed' do
    let(:include_youth_court_fee) { true }

    before { visit claimed_costs_additional_fees_nsm_steps_view_claim_path(claim.id) }

    it 'show the additional fees tab' do
      expect(all('table td, table th').map(&:text)).to eq(
        [
          'Item', 'Net cost', 'VAT', 'Total',
          'Profit costs', '£904.43', '£180.89', '£1,085.31',
          'Disbursements', '£327.50', '£31.50', '£359.00',
          'Travel', '£10.58', '£2.12', '£12.70',
          'Waiting', '£10.58', '£2.12', '£12.70',
          'Total',
          'Sum of net cost claimed: £1,253.09',
          'Sum of VAT on claimed: £216.62',
          'Sum of net cost and VAT on claimed: £1,469.71',
          'Fee type', 'Net cost claimed', 'Youth court', '£598.59'
        ]
      )
    end

    it 'shows additional fee page with claimed costs' do
      click_on 'Youth court'
      expect(find('h1').text).to eq('Additional fees')
      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Your claimed costs',
          'Fee type', 'Youth court',
          'Net cost claimed', '£598.59'
        ]
      )
    end

    context 'when the claim is not NSM' do
      let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

      it 'does not show the additional fee tab' do
        expect(page).to have_no_content 'Additional Fees'
      end
    end

    context 'when the youth_court field is no' do
      let(:youth_court) { 'no' }

      it 'does not show the additional fee tab' do
        expect(page).to have_no_content 'Additional Fees'
      end
    end

    context 'when the date is too early' do
      let(:rep_order_date) { Constants::YOUTH_COURT_CUTOFF_DATE - 1 }

      it 'does not show the additional fee tab' do
        expect(page).to have_no_content 'Additional Fees'
      end
    end

    context 'when additional fee has been adjusted' do
      let(:assessment_comment) { 'assessed' }
      let(:youth_court_fee_adjustment_comment) { 'removed fee' }
      let(:allowed_youth_court_fee) { false }
      let(:state) { :part_grant }

      it 'shows additional fee tab in adjusted costs' do
        click_on 'Adjusted costs'
        expect(page).to have_content 'Adjusted additional fees'
        click_on 'Adjusted additional fees'
        expect(all('table th, table td').map(&:text)).to include(
          'Fee type', 'Youth court',
          'Net cost allowed', '£0.00'
        )
      end

      it 'shows additional fee page with claimed and adjusted costs' do
        click_on 'Youth court'
        expect(find('h1').text).to eq('Additional fees')
        expect(all('table caption, table td').map(&:text)).to eq(
          [
            'Adjusted claim',
            'Fee type', 'Youth court',
            'Net cost allowed', '£0.00',
            'Reason for adjustment', 'removed fee',
            'Your claimed costs',
            'Fee type', 'Youth court',
            'Net cost claimed', '£598.59'
          ]
        )
      end
    end
  end

  it 'show the disbursements page' do
    visit claimed_costs_disbursements_nsm_steps_view_claim_path(claim.id)

    expect(all('table td, table th').map(&:text)).to eq(
      [
        'Item', 'Net cost', 'VAT', 'Total',
        'Profit costs', '£305.84', '£61.17', '£367.01',
        'Disbursements', '£327.50', '£31.50', '£359.00',
        'Travel', '£10.58', '£2.12', '£12.70',
        'Waiting', '£10.58', '£2.12', '£12.70',
        'Total',
        'Sum of net cost claimed: £654.50',
        'Sum of VAT on claimed: £96.90',
        'Sum of net cost and VAT on claimed: £751.40',
        'Item', 'Cost type', 'Date', 'Net cost claimed', 'VAT on claimed', 'Total claimed',
        '1', 'Car mileage', 5.days.ago.to_fs(:short_stamp), '£90.00', '£18.00', '£108.00',
        '2', 'Custom', 3.days.ago.to_fs(:short_stamp), '£40.00', '£0.00', '£40.00',
        '3', 'DNA Testing', 3.days.ago.to_fs(:short_stamp), '£130.00', '£0.00', '£130.00',
        '4', 'Car mileage', 2.days.ago.to_fs(:short_stamp), '£67.50', '£13.50', '£81.00'
      ]
    )
  end

  it 'show a work item' do
    visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :work_item, item_id: work_items.first.id)

    expect(all('table caption, table td').map(&:text)).to eq(
      [
        'Provider submission',
        'Work type',
        'Attendance without counsel',
        'Date',
        1.day.ago.to_fs(:stamp),
        'Fee earner initials',
        'AB',
        'Time claimed',
        '1 hour 30 minutes',
        'Uplift claimed',
        '0%',
        'Net cost claimed',
        '£78.23'
      ]
    )
  end

  it 'show letters' do
    visit letters_nsm_steps_view_claim_path(id: claim.id)

    expect(find('h1').text).to eq('Letters')
    expect(all('table caption, table td').map(&:text)).to eq(
      [
        'Your claimed costs',
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
        'Your claimed costs',
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
        'Your claimed costs',
        'Date',	5.days.ago.to_fs(:stamp),
        'Disbursement type', 'Car mileage',
        'Disbursement description', 'Details',
        'Prior authority granted?', 'No',
        'Mileage', '200 miles',
        'Net cost', '£90.00',
        'VAT', '£18.00',
        'Total cost', '£108.00'
      ]
    )
  end

  context 'when adjustments exist' do
    let(:claim) do
      create(:claim, :case_type_magistrates, :complete, :adjusted_letters_calls, office_in_undesignated_area: true,
             court_in_undesignated_area: true, firm_office: firm_office, reasons_for_claim: ['extradition'],
             assigned_counsel: 'yes', state: state, work_items: work_items, disbursements: disbursements,
             assessment_comment: assessment_comment)
    end

    let(:firm_office) { build(:firm_office, :full, :valid) }

    let(:assessment_comment) { 'some random text' }

    let(:state) { :part_grant }

    let(:work_items) do
      [
        build(:work_item, :valid, :travel, :with_adjustment, fee_earner: 'BC', completed_on: 6.days.ago, time_spent: 60),
        build(:work_item, :valid, :waiting, :with_adjustment, fee_earner: 'BC', completed_on: 5.days.ago, time_spent: 60),
        build(:work_item, :valid, :attendance_with_counsel, :with_adjustment, fee_earner: 'AB', completed_on: 4.days.ago,
              time_spent: 90),
        build(:work_item, :valid, :attendance_without_counsel, :with_adjustment, fee_earner: 'AB', completed_on: 3.days.ago,
              time_spent: 90),
        build(:work_item, :valid, :preparation, :with_adjustment, fee_earner: 'BC', completed_on: 2.days.ago, time_spent: 104),
        build(:work_item, :valid, :advocacy, :with_adjustment, fee_earner: 'BC', completed_on: 1.day.ago, time_spent: 104),
      ]
    end

    let(:disbursements) do
      [
        build(:disbursement, :valid_other, :dna_testing, age: 3, total_cost_without_vat: 130),
        build(:disbursement, :valid, :with_adjustment, :bike, age: 5, miles: 200, allowed_miles: 100),
        build(:disbursement, :valid_other, :with_adjustment, :dna_testing, age: 4,
              total_cost_without_vat: 150, allowed_total_cost_without_vat: 100),
      ]
    end

    it 'shows the Overview, Claimed and Adjusted tabs' do
      visit nsm_steps_view_claim_path(claim.id)

      within('.govuk-summary-card', text: 'Claim status') do
        expect(page)
          .to have_content('£833.42 claimed')
          .and have_content('£504.26 allowed')
      end

      expect(page)
        .to have_link('Overview')
        .and have_link('Claimed costs')
        .and have_link('Adjusted costs')
    end

    context 'with granted claims' do
      let(:state) { :granted }

      it 'shows the adjusted/allowed amount' do
        visit nsm_steps_view_claim_path(claim.id)

        # NOTE: granted claims will only have increased allowed
        # amounts going forward (see CRM457-1679) but this excercises
        # the fact that granteds should show adjusted amounts for transpanrency.
        within('.govuk-summary-card', text: 'Claim status') do
          expect(page)
            .to have_content('£833.42 claimed')
            .and have_content('£504.26 allowed')
        end
      end

      it 'shows the Overview, Claimed and Adjusted tabs' do
        visit nsm_steps_view_claim_path(claim.id)

        expect(page)
          .to have_link('Overview')
          .and have_link('Claimed costs')
          .and have_link('Adjusted costs')
      end
    end

    context 'case disposal' do
      # rubocop:disable Style/HashSyntax
      let(:claim) do
        create(:claim, :case_type_magistrates, :complete, :letters_calls,
               :letters_calls, firm_office:,
               work_items:, disbursements:,
               plea:, plea_category:,
               include_youth_court_fee:,
               rep_order_date:,
               state: :submitted)
      end
      # rubocop:enable Style/HashSyntax

      let(:plea) { :guilty }
      let(:plea_category) { :category_1a }
      let(:include_youth_court_fee) { nil }
      let(:rep_order_date) { Constants::YOUTH_COURT_CUTOFF_DATE }
      let(:firm_office) { build(:firm_office, :full, :valid) }

      context 'youth_court_fee enabled' do
        let(:youth_court_fee_enabled) { true }

        before do
          allow(FeatureFlags).to receive(:youth_court_fee).and_return(double(:youth_court_fee, enabled?: youth_court_fee_enabled))
        end

        describe 'include_youth_court_fee true' do
          let(:include_youth_court_fee) { true }

          it 'show case outcome category, plea and additional fee claimed message' do
            visit nsm_steps_view_claim_path(claim.id)

            within('.govuk-summary-card', text: 'Case disposal') do
              expect(page).to have_content('Category 1A')
              expect(page).to have_content('Guilty')
              expect(page).to have_content('Additional fee')
              expect(page).to have_content('Youth court fee claimed')
            end
          end
        end

        describe 'include_youth_court_fee false' do
          let(:include_youth_court_fee) { false }

          it 'show additional fee with fee not claimed message' do
            visit nsm_steps_view_claim_path(claim.id)

            within('.govuk-summary-card', text: 'Case disposal') do
              expect(page).to have_content('Category 1A')
              expect(page).to have_content('Guilty')
              expect(page).to have_content('Additional fee')
              expect(page).to have_content('Youth court fee not claimed')
            end
          end
        end

        describe 'include_youth_court_fee is nil' do
          it 'does not show Additional Fee if ineligible for YCF' do
            visit nsm_steps_view_claim_path(claim.id)

            within('.govuk-summary-card', text: 'Case disposal') do
              expect(page).to have_content('Category 1A')
              expect(page).to have_content('Guilty')
              expect(page).not_to have_content('Additional fee')
            end
          end
        end

        describe 'backwards compatible with pre-YCF change claims' do
          let(:rep_order_date) { Constants::YOUTH_COURT_CUTOFF_DATE - 1.day }
          let(:plea_category) { :non_guilty_pleas }
          let(:plea) { :cracked_trial }

          it 'shows pre-6th dec categories' do
            visit nsm_steps_view_claim_path(claim.id)

            within('.govuk-summary-card', text: 'Case disposal') do
              expect(page).to have_content('Category 2')
              expect(page).to have_content('Cracked trial')
              expect(page).not_to have_content('Additional fee')
            end
          end
        end
      end

      describe 'include_youth_court_fee disabled' do
        let(:youth_court_fee_enabled) { false }
        let(:include_youth_court_fee) { nil }

        before do
          allow(FeatureFlags).to receive(:youth_court_fee).and_return(double(:youth_court_fee, enabled?: youth_court_fee_enabled))
        end

        describe 'shows generic category title and plea outcome' do
          it 'show pre-youth court changes case disposal view' do
            visit nsm_steps_view_claim_path(claim.id)

            within('.govuk-summary-card', text: 'Case disposal') do
              expect(page).to have_content('Category')
              expect(page).to have_content('Guilty plea')
              expect(page).not_to have_content('Additional fee')
            end
          end
        end
      end
    end

    context 'with rejected claims' do
      let(:state) { :rejected }

      it 'shows the £0.00 for allowed amount' do
        visit nsm_steps_view_claim_path(claim.id)

        within('.govuk-summary-card', text: 'Claim status') do
          expect(page)
            .to have_content('£833.42 claimed')
            .and have_content('£0.00 allowed')
        end
      end

      it 'shows the Overview and Claimed tabs (only)' do
        visit nsm_steps_view_claim_path(claim.id)

        expect(page)
          .to have_link('Overview')
          .and have_link('Claimed costs')
          .and have_no_link('Adjusted costs')
      end

      it 'lets me download a PDF' do
        visit nsm_steps_view_claim_path(claim.id)
        click_on 'Create a printable PDF'
        expect(page).to have_current_path download_nsm_steps_view_claim_path(claim)
        expect(page.driver.response.headers['Content-Type']).to eq 'application/pdf'
      end
    end

    it 'shows an adjusted cost summary table with VAT' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      expect(page).to have_no_selector('.govuk-summary-card', text: 'Cost summary')
      expect(page).to have_selector('.govuk-table__caption', text: 'Cost summary')

      expect(all('#cost-summary-table table td, #cost-summary-table table th').map(&:text)).to eq(
        [
          'Item', 'Net cost claimed', 'VAT claimed', 'Total claimed', 'Net cost allowed', 'VAT allowed', 'Total allowed',
          'Profit costs', '£355.98', '£71.20', '£427.18', '£175.95', '£35.19', '£211.14',
          'Disbursements', '£330.00', '£10.00', '£340.00', '£255.00', '£5.00', '£260.00',
          'Travel', '£27.60', '£5.52', '£33.12', '£13.80', '£2.76', '£16.56',
          'Waiting', '£27.60', '£5.52', '£33.12', '£13.80', '£2.76', '£16.56',
          'Total',
          'Sum of net cost claimed: £741.18',
          'Sum of VAT on claimed: £92.24',
          'Sum of net cost and VAT on claimed: £833.42',
          'Sum of net cost allowed: £458.55',
          'Sum of VAT on allowed: £45.71',
          'Sum of net cost and VAT on allowed: £504.26'
        ]
      )
    end

    context 'when firm is NOT VAT registered' do
      let(:firm_office) { build(:firm_office, :full, :valid, vat_registered: 'no') }

      it 'shows an adjusted cost summary table without VAT' do
        visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

        expect(page).to have_no_selector('.govuk-summary-card', text: 'Cost summary')
        expect(page).to have_selector('.govuk-table__caption', text: 'Cost summary')

        expect(all('#cost-summary-table table td, #cost-summary-table table th').map(&:text)).to eq(
          [
            'Item', 'Net cost claimed', 'VAT claimed', 'Total claimed', 'Net cost allowed', 'VAT allowed', 'Total allowed',
            'Profit costs', '£355.98', '£0.00', '£355.98', '£175.95', '£0.00', '£175.95',
            'Disbursements', '£330.00', '£10.00', '£340.00', '£255.00', '£5.00', '£260.00',
            'Travel', '£27.60', '£0.00', '£27.60', '£13.80', '£0.00', '£13.80',
            'Waiting', '£27.60', '£0.00', '£27.60', '£13.80', '£0.00', '£13.80',
            'Total',
            'Sum of net cost claimed: £741.18',
            'Sum of VAT on claimed: £10.00',
            'Sum of net cost and VAT on claimed: £751.18',
            'Sum of net cost allowed: £458.55',
            'Sum of VAT on allowed: £5.00',
            'Sum of net cost and VAT on allowed: £463.55'
          ]
        )
      end
    end

    it 'show the adjusted work item summary' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      # open summary
      find('details').click
      expect(page).to have_selector('caption.govuk-visually-hidden', text: 'Summary of adjusted work items')

      expect(all('details table td, details table th').map(&:text)).to eq(
        [
          '', 'Time claimed', 'Net cost claimed', 'Time allowed', 'Net cost allowed',
          'Travel', '1 hour:00 minutes', '£27.60', '0 hours:30 minutes', '£13.80',
          'Waiting', '1 hour:00 minutes', '£27.60', '0 hours:30 minutes', '£13.80',
          'Attendance with counsel', '1 hour:30 minutes', '£53.52', '0 hours:45 minutes', '£26.76',
          'Attendance without counsel', '1 hour:30 minutes', '£78.23', '0 hours:45 minutes', '£39.11',
          'Preparation', '1 hour:44 minutes', '£90.39', '0 hours:52 minutes', '£45.20',
          'Advocacy', '1 hour:44 minutes', '£113.39', '0 hours:52 minutes', '£56.70',
          'Total', '', 'Sum of net cost claimed: £390.73', '', 'Sum of net cost allowed: £195.37'
        ]
      )
    end

    it 'show the adjusted work items' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      within('table', text: 'Adjusted work items') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted work items',
            'Item', 'Cost type', 'Reason for adjustment', 'Time allowed', 'Uplift allowed', 'Net cost allowed',
            '1', 'Travel', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '2', 'Waiting', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '3', 'Attendance with counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£26.76',
            '4', 'Attendance without counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£39.11',
            '5', 'Preparation', 'WI adjustment', '0 hours:52 minutes', '0%', '£45.20',
            '6', 'Advocacy', 'WI adjustment', '0 hours:52 minutes', '0%', '£56.70',
          ]
        )
      end
    end

    it 'shows expected pagination' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      expect(page).to have_content("Showing #{claim.work_items.size} of #{claim.work_items.size} work items")
    end

    it 'allows me to sort adjusted work items by Cost type' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      click_on 'Cost type'

      within('table', text: 'Adjusted work items') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted work items',
            'Item', 'Cost type', 'Reason for adjustment', 'Time allowed', 'Uplift allowed', 'Net cost allowed',
            '6', 'Advocacy', 'WI adjustment', '0 hours:52 minutes', '0%', '£56.70',
            '3', 'Attendance with counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£26.76',
            '4', 'Attendance without counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£39.11',
            '5', 'Preparation', 'WI adjustment', '0 hours:52 minutes', '0%', '£45.20',
            '1', 'Travel', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '2', 'Waiting', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
          ]
        )
      end
    end

    it 'allows me to sort adjusted work items by Time allowed' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      click_on 'Time allowed'

      within('table', text: 'Adjusted work items') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted work items',
            'Item', 'Cost type', 'Reason for adjustment', 'Time allowed', 'Uplift allowed', 'Net cost allowed',
            '1', 'Travel', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '2', 'Waiting', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '3', 'Attendance with counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£26.76',
            '4', 'Attendance without counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£39.11',
            '5', 'Preparation', 'WI adjustment', '0 hours:52 minutes', '0%', '£45.20',
            '6', 'Advocacy', 'WI adjustment', '0 hours:52 minutes', '0%', '£56.70',
          ]
        )
      end
    end

    it 'allows me to sort adjusted work items by Uplift allowed' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      click_on 'Uplift allowed'

      within('table', text: 'Adjusted work items') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted work items',
            'Item', 'Cost type', 'Reason for adjustment', 'Time allowed', 'Uplift allowed', 'Net cost allowed',
            '3', 'Attendance with counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£26.76',
            '4', 'Attendance without counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£39.11',
            '5', 'Preparation', 'WI adjustment', '0 hours:52 minutes', '0%', '£45.20',
            '6', 'Advocacy', 'WI adjustment', '0 hours:52 minutes', '0%', '£56.70',
            '1', 'Travel', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '2', 'Waiting', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
          ]
        )
      end
    end

    it 'allows me to sort adjusted work items by Net cost allowed' do
      visit adjustments_work_items_nsm_steps_view_claim_path(claim.id)

      click_on 'Net cost allowed'

      within('table', text: 'Adjusted work items') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted work items',
            'Item', 'Cost type', 'Reason for adjustment', 'Time allowed', 'Uplift allowed', 'Net cost allowed',
            '1', 'Travel', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '2', 'Waiting', 'WI adjustment', '0 hours:30 minutes', '10%', '£13.80',
            '3', 'Attendance with counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£26.76',
            '4', 'Attendance without counsel', 'WI adjustment', '0 hours:45 minutes', '0%', '£39.11',
            '5', 'Preparation', 'WI adjustment', '0 hours:52 minutes', '0%', '£45.20',
            '6', 'Advocacy', 'WI adjustment', '0 hours:52 minutes', '0%', '£56.70',
          ]
        )
      end
    end

    it 'shows the letters and calls page' do
      visit adjustments_letters_and_calls_nsm_steps_view_claim_path(claim.id)

      within('table', text: 'Adjusted letter and calls') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted letter and calls',
            'Cost type', 'Reasons for adjustment', 'Number allowed', 'Uplift allowed', 'Net cost allowed',
            'Letters', 'Letters adjusted', '1', '0%', '£4.09',
            'Calls', 'Calls adjusted', '1', '0%', '£4.09'
          ]
        )
      end
    end

    it 'show the disbursements page' do
      visit adjustments_disbursements_nsm_steps_view_claim_path(claim.id)

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00', '2', 'DNA Testing', 'Disbursement Test',
            '£100.00', '£0.00', '£100.00'
          ]
        )
      end
    end

    it 'allows me to sort adjusted disbursements by Cost type' do
      visit adjustments_disbursements_nsm_steps_view_claim_path(claim.id)

      click_on 'Cost type'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
          ]
        )
      end

      click_on 'Cost type'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
          ]
        )
      end
    end

    it 'allows me to sort adjusted disbursements by Net cost allowed' do
      visit adjustments_disbursements_nsm_steps_view_claim_path(claim.id)

      click_on 'Net cost allowed'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
          ]
        )
      end

      click_on 'Net cost allowed'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
          ]
        )
      end
    end

    it 'allows me to sort adjusted disbursements by VAT on allowed' do
      visit adjustments_disbursements_nsm_steps_view_claim_path(claim.id)

      click_on 'VAT on allowed'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
          ]
        )
      end

      click_on 'VAT on allowed'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
          ]
        )
      end
    end

    it 'allows me to sort adjusted disbursements by Total cost allowed' do
      visit adjustments_disbursements_nsm_steps_view_claim_path(claim.id)

      click_on 'Total cost allowed'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
          ]
        )
      end

      click_on 'Total cost allowed'

      within('table', text: 'Adjusted disbursements') do
        expect(all('caption, td, th').map(&:text)).to eq(
          [
            'Adjusted disbursements',
            'Item', 'Cost type', 'Reason for adjustment', 'Net cost allowed', 'VAT on allowed', 'Total cost allowed',
            '2', 'DNA Testing', 'Disbursement Test', '£100.00', '£0.00', '£100.00',
            '1', 'Bike mileage', 'Disbursement Test', '£25.00', '£5.00', '£30.00',
          ]
        )
      end
    end

    it 'show a work item' do
      visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :work_item, item_id: work_items.last.id)

      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Provider submission',
          'Work type', 'Advocacy',
          'Date', 1.day.ago.to_fs(:stamp),
          'Fee earner initials', 'BC',
          'Time claimed', '1 hour 44 minutes',
          'Uplift claimed', '0%',
          'Net cost claimed', '£113.39',
          'LAA adjustments',
          'Work type', 'Advocacy',
          'Time allowed', '0 hours 52 minutes',
          'Uplift allowed', '0%',
          'Net cost allowed', '£56.70',
          'Reason for adjustment', 'WI adjustment'
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
          'Your claimed costs',
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
          'Your claimed costs',
          'Rate applied', '£4.09',
          'Number of calls', '3',
          'Uplift', '0%',
          'Net cost', '£12.27'
        ]
      )
    end

    it 'show a disbursement' do
      visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :disbursement, item_id: disbursements.last.id)

      expect(find('h1').text).to eq('DNA Testing')

      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Adjusted claim',
          'Net cost allowed', '£100.00',
          'VAT allowed', '£0.00',
          'Total cost allowed', '£100.00',
          'Reason for adjustment', 'Disbursement Test',
          'Your claimed costs',
          'Date', 4.days.ago.to_fs(:stamp),
          'Disbursement type', 'DNA Testing',
          'Disbursement description', 'Details',
          'Prior authority granted?', 'Yes',
          'Net cost', '£150.00',
          'VAT', '£0.00',
          'Total cost', '£150.00'
        ]
      )
    end

    it 'show a disbursement - with miles' do
      disbursement = claim.disbursements.find_by(disbursement_type: :bike)
      visit item_nsm_steps_view_claim_path(id: claim.id, item_type: :disbursement, item_id: disbursement.id)

      expect(find('h1').text).to eq('Bike mileage')

      expect(all('table caption, table td').map(&:text)).to eq(
        [
          'Adjusted claim',
          'Mileage allowed', '100 miles',
          'Net cost allowed', '£25.00',
          'VAT allowed', '£5.00',
          'Total cost allowed', '£30.00',
          'Reason for adjustment', 'Disbursement Test',
          'Your claimed costs',
          'Date', 5.days.ago.to_fs(:stamp),
          'Disbursement type', 'Bike mileage',
          'Disbursement description', 'Details',
          'Prior authority granted?', 'No',
          'Mileage', '200 miles',
          'Net cost', '£50.00',
          'VAT', '£10.00',
          'Total cost', '£60.00'
        ]
      )
    end
  end

  it 'lets me download a PDF' do
    visit nsm_steps_view_claim_path(claim.id)
    click_on 'Create a printable PDF'
    expect(page).to have_current_path download_nsm_steps_view_claim_path(claim)
    expect(page.driver.response.headers['Content-Type']).to eq 'application/pdf'
  end

  context 'when claim is expired' do
    let(:claim) { create(:claim, :complete, :case_type_magistrates, state: :expired, further_informations: [fi]) }
    let(:fi) do
      build :further_information,
            requested_at: Date.new(2024, 8, 1),
            resubmission_deadline: Date.new(2024, 8, 10),
            information_requested: 'What is your quest?'
    end

    before { visit nsm_steps_view_claim_path(claim.id) }

    it 'shows me relevant information' do
      expect(page).to have_content('Expired')
        .and have_content('What is your quest?')
        .and have_content(
          'On 1 August 2024 we asked you to update your claim before we could complete the assessment. ' \
          'This was due by 10 August 2024. As this update was not made by the required date this ' \
          'claim has been automatically closed. If you make a new claim you should include the requested update.'
        )
    end
  end
end
