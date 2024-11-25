require 'rails_helper'

RSpec.describe 'Youth court claim additional fee', type: :system do
  let(:claim) { create(:claim, :complete) }
  let(:youth_court_fee_enabled) { nil }

  before do
    allow(FeatureFlags).to receive(:youth_court_fee).and_return(double(:youth_court_fee, enabled?: youth_court_fee_enabled))
    visit provider_saml_omniauth_callback_path
    visit edit_nsm_steps_youth_court_claim_additional_fee_path(claim.id)
  end

  context 'Feature flag for youth_court_fee is disabled' do
    let(:youth_court_fee_enabled) { false }

    it 'cannot access the case_category route' do
      expect(page).to have_content('No route matches')
    end
  end

  context 'Feature flag for youth_court_fee is enabled' do
    let(:youth_court_fee_enabled) { true }

    it 'Lets me select an option' do
      choose 'Yes'

      click_on 'Save and continue'

      expect(claim.reload).to have_attributes(
        claimed_include_youth_court_fee: true
      )
    end

    it 'validates' do
      click_on 'Save and continue'

      expect(page).to have_content('Select the yes if you wish to claim the youth court addition fee')
    end
  end
end
