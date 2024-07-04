require 'rails_helper'

# These specs will not run unless the `INCLUDE_ACCESSIBILITY_SPECS` env var is set to `true`
RSpec.describe 'Accessibility', :accessibility do
  subject { page }

  before do
    driven_by(:headless_chrome)
    visit provider_saml_omniauth_callback_path
  end

  let(:provider) { create(:provider) }
  let(:application) { create(:prior_authority_application) }
  let(:claim) { create(:claim, :complete, :with_assessment_comment) }
  let(:be_axe_clean_with_caveats) do
    # Ignoring known false positive around skip links, see: https://design-system.service.gov.uk/components/skip-link/#when-to-use-this-component
    # Ignoring known false positive around aria-expanded attributes on conditional reveal radios, see: https://github.com/alphagov/govuk-frontend/issues/979
    be_axe_clean.excluding('.govuk-skip-link')
                .skipping('aria-allowed-attr')
  end

  context 'when viewing general screenss' do
    %i[
      root
      about_cookies
      about_privacy
      about_contact
      about_accessibility
      nsm_applications
      prior_authority_applications
    ].each do |path|
      describe "#{path} screen" do
        before { visit send(:"#{path}_path") }

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end

  context 'when viewing NSM claim screens' do
    %i[
      edit_nsm_steps_claim_type
      nsm_steps_start_page
      edit_nsm_steps_firm_details
      edit_nsm_steps_office_code
      edit_nsm_steps_case_details
      edit_nsm_steps_case_disposal
      edit_nsm_steps_hearing_details
      edit_nsm_steps_defendant_summary

      edit_nsm_steps_reason_for_claim
      edit_nsm_steps_claim_details
      edit_nsm_steps_letters_calls

      edit_nsm_steps_work_items

      edit_nsm_steps_disbursement_add
      edit_nsm_steps_disbursements
      nsm_steps_cost_summary
      edit_nsm_steps_other_info
      edit_nsm_steps_supporting_evidence
      edit_nsm_steps_equality
      edit_nsm_steps_equality_questions
      edit_nsm_steps_solicitor_declaration
      nsm_steps_claim_confirmation
      nsm_steps_check_answers
      nsm_steps_view_claim
    ].each do |path|
      describe "#{path} screen" do
        before { visit send(:"#{path}_path", claim) }

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end

  context 'when viewing NSM claim sub-items' do
    %i[
      edit_nsm_steps_defendant_details
      edit_nsm_steps_defendant_delete
      duplicate_nsm_steps_work_item
      edit_nsm_steps_work_item_delete
      edit_nsm_steps_work_item
      edit_nsm_steps_disbursement_type
      edit_nsm_steps_disbursement_cost
      edit_nsm_steps_disbursement_delete
    ].each do |path|
      describe "#{path} screen" do
        before { visit send(:"#{path}_path", claim, Nsm::StartPage::NEW_RECORD) }

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end

  context 'when viewing PA further information screen' do
    describe 'edit_prior_authority_steps_further_information screen' do
      let(:application) { create(:prior_authority_application, :with_further_information_request) }

      before { visit send(:edit_prior_authority_steps_further_information_path, application) }

      it 'is accessible' do
        expect(page).to(be_axe_clean_with_caveats)
      end
    end
  end

  context 'when viewing PA application screens' do
    %i[
      edit_prior_authority_steps_prison_law
      edit_prior_authority_steps_authority_value
      prior_authority_steps_start_page
      edit_prior_authority_steps_ufn
      edit_prior_authority_steps_case_contact
      edit_prior_authority_steps_office_code
      edit_prior_authority_steps_client_detail
      edit_prior_authority_steps_next_hearing
      edit_prior_authority_steps_case_detail
      edit_prior_authority_steps_hearing_detail
      edit_prior_authority_steps_youth_court
      edit_prior_authority_steps_psychiatric_liaison
      edit_prior_authority_steps_reason_why
      offboard_prior_authority_application
    ].each do |path|
      describe "#{path} screen" do
        before { visit send(:"#{path}_path", application) }

        it 'is accessible' do
          expect(page).to(be_axe_clean_with_caveats)
        end
      end
    end
  end
end
