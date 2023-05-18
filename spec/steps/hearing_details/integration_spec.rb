require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { Claim.create(office_code: 'AAAA') }

  before do
    visit provider_saml_omniauth_callback_path
  end

  xit 'can do green path' do
    visit edit_steps_hearing_details_path(claim.id)

    fill_in

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      plea: PleaOptions::GUILTY.value.to_s,
    )
  end
end
