require 'rails_helper'

RSpec.describe 'User can manage work items', type: :system do
  let(:claim) { create(:claim) }

  before do
    visit provider_saml_omniauth_callback_path
  end

  it 'can add a work item' do
    visit edit_nsm_steps_equality_path(claim.id)

    choose 'Yes, answer the equality questions (takes 2 minutes)'

    expect { click_on 'Save and continue' }.not_to change(claim.reload, :attributes)
  end
end
