require 'rails_helper'

RSpec.describe 'User can provide supporting evidence', type: :system do
  let(:claim) { create(:claim, :complete) }

  it 'does not show the mail address' do
    visit provider_saml_omniauth_callback_path

    visit edit_nsm_steps_supporting_evidence_path(claim.id)

    element = find_by_id('steps-supporting-evidence-form-send-by-post-true-field', visible: :all)

    expect(element).not_to be_checked

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(send_by_post: false)
  end

  it 'does shows the mail address' do
    visit provider_saml_omniauth_callback_path

    visit edit_nsm_steps_supporting_evidence_path(claim.id)

    element = find_by_id('steps-supporting-evidence-form-send-by-post-true-field', visible: :all)

    element.click

    expect(element).to be_checked

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(send_by_post: true)
  end
end
