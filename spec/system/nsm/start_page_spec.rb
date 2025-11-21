require 'rails_helper'

RSpec.describe 'User can see an application status', type: :system do
  let(:claim) { create(:claim, ufn:, solicitor:, firm_office:, claim_type:, rep_order_date:, gdpr_documents_deleted:) }
  let(:ufn) { '120223/001' }
  let(:firm_office) { FirmOffice.create }
  let(:solicitor) { Solicitor.create(first_name: 'James', last_name: 'Robest') }
  let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE }
  let(:rep_order_date) { Date.yesterday }
  let(:gdpr_documents_deleted) { false }

  before do
    claim.update(viewed_steps: ['firm_details'])
    visit provider_entra_id_omniauth_callback_path
  end

  it 'can do green path' do
    visit nsm_steps_start_page_path(claim.id)
    within('.govuk-task-list__item', text: 'Firm details') do
      expect(page).to have_content('In progress')
      expect(page).not_to have_content('Your uploaded files have been deleted because there was no activity')
    end
  end

  context 'when claim_type is not set' do
    let(:claim_type) { nil }

    it 'raises an error when generating the path' do
      error_msg = "Claim with id: #{claim.id} has an invalid claim type"
      expect { visit nsm_steps_start_page_path(claim.id) }.to raise_error error_msg
    end
  end

  context 'when documents have been removed due to gdpr' do
    let(:gdpr_documents_deleted) { true }

    it 'shows flash indicating provider needs to check supporting evidence' do
      visit nsm_steps_start_page_path(claim.id)
      expect(page).to have_content('Your uploaded files have been deleted because there was no activity')
    end
  end
end
