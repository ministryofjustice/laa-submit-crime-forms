require 'rails_helper'

RSpec.describe 'User can see an application status', type: :system do
  let(:firm_office) { FirmOffice.create }
  let(:solicitor) { Solicitor.create(full_name: 'James Robert') }
  let(:claim) { Claim.create(office_code: 'AAAA', solicitor: solicitor, firm_office: firm_office) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit steps_start_page_path(claim.id)

    within('.moj-task-list__item', text: 'Your details') do
      expect(page).to have_content('In progress')
    end
  end
end
