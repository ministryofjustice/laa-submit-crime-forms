require 'rails_helper'

RSpec.describe 'User can see an application status', type: :system do
  let(:claim) { Claim.create(office_code:, solicitor:, firm_office:, claim_type:, rep_order_date:) }

  let(:firm_office) { FirmOffice.create }
  let(:solicitor) { Solicitor.create(full_name: 'James Robert') }
  let(:office_code) { 'AAA' }
  let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE }
  let(:rep_order_date) { Date.yesterday }

  before do
    claim.update(navigation_stack: ["/applications/#{claim.id}/steps/firm_details"])
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit steps_start_page_path(claim.id)

    within('.moj-task-list__item', text: 'Your details') do
      expect(page).to have_content('In progress')
    end
  end
end
