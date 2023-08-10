require 'rails_helper'

RSpec.describe 'User can fill in claim type details', type: :system do
  let(:claim) { create(:claim) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_steps_case_disposal_path(claim.id)

    choose 'Guilty plea'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      plea: PleaOptions::GUILTY.value.to_s,
    )
  end
end
