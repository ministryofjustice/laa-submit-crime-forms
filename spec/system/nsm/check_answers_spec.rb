require 'rails_helper'

RSpec.describe 'Check answers page', type: :system do
  let(:claim) { create(:claim, :case_type_breach, :firm_details, :letters_calls, work_items:, disbursements:, rep_order_date:) }
  let(:rep_order_date) { Constants::YOUTH_COURT_CUTOFF_DATE - 1.day }
  let(:work_items) do
    [
      build(:work_item, :valid, :attendance_without_counsel, time_spent: 90),
      build(:work_item, :valid, :advocacy, time_spent: 104),
      build(:work_item, :valid, :advocacy, time_spent: 86),
      build(:work_item, :valid, :waiting, time_spent: 23),
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

  context 'case disposal' do
    let(:claim) do
      create(:claim, :case_type_magistrates, :firm_details,
             :letters_calls, work_items:, disbursements:, plea:, plea_category:,
            include_youth_court_fee:, rep_order_date:)
    end
    let(:youth_court_fee_enabled) { nil }
    let(:plea) { :guilty }
    let(:plea_category) { :category_1a }
    let(:include_youth_court_fee) { true }
    let(:rep_order_date) { Constants::YOUTH_COURT_CUTOFF_DATE }

    before do
      visit provider_saml_omniauth_callback_path
    end

    context 'enabled' do
      let(:youth_court_fee_enabled) { true }

      before do
        allow(FeatureFlags).to receive(:youth_court_fee).and_return(double(:youth_court_fee, enabled?: youth_court_fee_enabled))
      end

      describe 'youth court eligible' do
        it 'shows category type with category outcome and Additional Fee' do
          visit nsm_steps_check_answers_path(claim.id)

          within('.govuk-summary-card', text: 'Case disposal') do
            expect(page).to have_content('Category 1A')
            expect(page).to have_content('Guilty')
            expect(page).to have_content('Additional fee')
            expect(page).to have_content('Youth court fee claimed')
          end
        end
      end

      describe 'youth court inelligible' do
        let(:include_youth_court_fee) { nil }

        it 'shows category type with category outcome without Additional Fee' do
          visit nsm_steps_check_answers_path(claim.id)

          within('.govuk-summary-card', text: 'Case disposal') do
            expect(page).to have_content('Category 1A')
            expect(page).to have_content('Guilty')
          end
        end
      end

      context 'backwards compatible with pre-YCF change claims' do
        let(:include_youth_court_fee) { nil }
        let(:plea_category) { :guilty_pleas }
        let(:plea) { :guilty }

        before do
          claim.update!(rep_order_date:)
        end

        it 'shows pre-6th Dec plea outcome flow' do
          visit nsm_steps_check_answers_path(claim.id)

          within('.govuk-summary-card', text: 'Case disposal') do
            expect(page).to have_content('Category 1')
            expect(page).to have_content('Guilty plea')
            expect(page).not_to have_content('Additional fee')
          end
        end

        describe 'flag disabled' do
          let(:youth_court_fee_enabled) { false }

          before do
            allow(FeatureFlags).to receive(:youth_court_fee)
              .and_return(double(:youth_court_fee, enabled?: youth_court_fee_enabled))
          end

          it 'shows the correct data within the case disposal section' do
            visit nsm_steps_check_answers_path(claim.id)

            within('.govuk-summary-card', text: 'Case disposal') do
              expect(page).to have_content('Category')
              expect(page).to have_content('Guilty plea')
            end
          end
        end
      end
    end
  end
end
