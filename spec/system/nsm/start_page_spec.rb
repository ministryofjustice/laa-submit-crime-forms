require 'rails_helper'

RSpec.describe 'User can see an application status', type: :system do
  let(:claim) { create(:claim, ufn:, solicitor:, firm_office:, claim_type:, rep_order_date:) }
  let(:ufn) { '120223/001' }
  let(:firm_office) { FirmOffice.create }
  let(:solicitor) { Solicitor.create(first_name: 'James', last_name: 'Robest') }
  let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE }
  let(:rep_order_date) { Date.yesterday }

  before do
    claim.update(navigation_stack: ["/non-standard-magistrates/applications/#{claim.id}/steps/firm_details"])
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit nsm_steps_start_page_path(claim.id)
    within('.govuk-task-list__item', text: 'Your details') do
      expect(page).to have_content('In progress')
    end
  end
end
