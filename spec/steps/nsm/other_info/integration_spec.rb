require 'rails_helper'

RSpec.describe 'User can fill in other relevent information', type: :system do
  let(:claim) { create(:claim, :complete) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_nsm_steps_other_info_path(claim.id)

    find('.govuk-form-group', text: 'Do you want to add any other information?').choose 'Yes'
    fill_in 'Add other information',
            with: 'any other relevent information'
    find('.govuk-form-group', text: 'Did the proceedings conclude over 3 months ago?').choose 'Yes'
    fill_in 'Tell us why you did not make this claim within 3 months of the conclusion of the proceedings',
            with: 'conclusion'
    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      is_other_info: 'yes',
      other_info: 'any other relevent information',
      concluded: 'yes',
      conclusion: 'conclusion'
    )
  end
end
