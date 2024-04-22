require 'rails_helper'

RSpec.describe 'User can provide supporting evidence', type: :system do
  let(:claim) { create(:claim, :complete) }

  context 'when postal evidence feature is enabled' do
    before do
      allow(FeatureFlags).to receive(:postal_evidence).and_return(double(:postal_evidence, enabled?: true))
    end

    it 'does not show the mail address' do
      visit provider_saml_omniauth_callback_path

      visit edit_nsm_steps_supporting_evidence_path(claim.id)

      element = find_by_id('nsm-steps-supporting-evidence-form-send-by-post-true-field', visible: :all)

      expect(element).not_to be_checked

      click_on 'Save and continue'

      expect(claim.reload).to have_attributes(send_by_post: false)
    end

    it 'does shows the mail address' do
      visit provider_saml_omniauth_callback_path

      visit edit_nsm_steps_supporting_evidence_path(claim.id)

      element = find_by_id('nsm-steps-supporting-evidence-form-send-by-post-true-field', visible: :all)

      element.click

      expect(element).to be_checked

      click_on 'Save and continue'

      expect(claim.reload).to have_attributes(send_by_post: true)
    end
  end

  context 'when postal evidence feature is disabled' do
    before do
      allow(FeatureFlags).to receive(:postal_evidence).and_return(double(:postal_evidence, enabled?: false))
      visit provider_saml_omniauth_callback_path
      visit edit_nsm_steps_supporting_evidence_path(claim.id)
    end

    it 'does not show the mail address' do
      expect(page).to have_no_css('#nsm-steps-supporting-evidence-form-send-by-post-true-field')
    end

    context 'when there is no supporting evidence' do
      before { claim.supporting_evidence.destroy_all }

      it 'validates' do
        click_on 'Save and continue'
        expect(page).to have_content 'Select a file to upload'
      end
    end
  end
end
