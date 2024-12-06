require 'rails_helper'

RSpec.describe 'When filling in the case outcome', :stub_app_store_search, :stub_oauth_token, type: :system do
  let(:claim) { create(:claim, plea_category: 'category_1a') }

  before do
    visit provider_saml_omniauth_callback_path
    allow(FeatureFlags).to receive(:youth_court_fee).and_return(double(:youth_court_fee, enabled?: feature_enabled))
    visit edit_nsm_steps_case_outcome_path(claim.id)
  end

  context 'and the feature flag is enabled' do
    let(:feature_enabled) { true }

    it 'the user is able to submit an outcome' do
      expect(page).to have_content(I18n.t('nsm.steps.case_outcome.edit.legend'))

      choose 'Guilty'
      click_on 'Save and continue'

      expect(claim.reload).to have_attributes(plea: CaseOutcome::GUILTY.to_s)
    end
  end

  context 'and the feature flag is disabled' do
    let(:feature_enabled) { false }

    it 'the user is not able to visit the page' do
      expect(page).to have_no_content(I18n.t('nsm.steps.case_outcome.edit.legend'))
      expect(page).to have_content('No route matches')
      expect(page).to have_http_status(:not_found)
    end
  end
end
