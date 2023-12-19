require 'rails_helper'

RSpec.describe 'User can manage work items', type: :system do
  let(:claim) { create(:claim) }

  before do
    visit user_saml_omniauth_callback_path
  end

  it 'can add a work item' do
    visit edit_steps_equality_path(claim.id)

    choose 'Yes, answer the equality questions (takes 2 minutes)'

    expect { click_on 'Save and continue' }.not_to change(claim.reload, :attributes)

    choose 'White British'
    choose 'Male'
    choose 'No'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      gender: 'm',
      ethnic_group: '01_white_british',
      disability: 'n'
    )
  end
end
