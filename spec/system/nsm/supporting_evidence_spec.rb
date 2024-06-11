require 'system_helper'

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

  context 'when all supporting evidence required options chosen' do
    before do
      claim.update!(assigned_counsel: 'yes', remitted_to_magistrate: 'yes', supplemental_claim: 'yes')
      claim.disbursements.first.update!(prior_authority: 'yes')

      visit provider_saml_omniauth_callback_path
      visit edit_nsm_steps_supporting_evidence_path(claim.id)
    end

    it 'displays all supporting evidence requirements' do
      expect(page)
        .to have_content('Based on your answers, you must upload:')
        .and have_content('If you do not upload this evidence, it might take longer to assess your claim.')
        .and have_content('CRM8 form')
        .and have_content('evidence of remittal')
        .and have_content('evidence of supplemental claim')
        .and have_content('prior authority certification')
    end
  end

  context 'when no supporting evidence required options chosen' do
    before do
      claim.update!(assigned_counsel: 'no', remitted_to_magistrate: 'no', supplemental_claim: 'no', wasted_costs: 'no')
      claim.disbursements.map { |d| d.update!(prior_authority: 'no') }

      visit provider_saml_omniauth_callback_path
      visit edit_nsm_steps_supporting_evidence_path(claim.id)
    end

    it 'does not display the supporting evidence requirements' do
      expect(page).to have_no_content 'Based on your answers'
      expect(page).to have_no_content 'If you do not upload this evidence'
    end
  end

  context 'when submitting evidence', :javascript, type: :system do
    let(:claim) { create(:claim) }

    before do
      visit provider_saml_omniauth_callback_path
      visit edit_nsm_steps_supporting_evidence_path(claim.id)
    end

    it 'Allows me to upload and delete evidence' do
      expect(page).to have_no_content('test_2.png')

      find('.moj-multi-file-upload__dropzone').drop(file_fixture('test_2.png'))

      within('.govuk-table') { expect(page).to have_content(/test_2.png\s+100%\s+Delete/) }

      click_on 'Delete'

      within('.moj-banner') { expect(page).to have_content('test_2.png has been deleted') }
      expect(page).to have_no_css('.govuk-table')
    end
  end
end
