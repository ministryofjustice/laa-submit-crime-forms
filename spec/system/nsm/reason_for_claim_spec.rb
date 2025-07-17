require 'rails_helper'

RSpec.describe 'User can fill in reason for claim', type: :system do
  let(:claim) { create(:claim) }

  before do
    visit provider_entra_id_omniauth_callback_path
  end

  it 'can do green path' do
    visit edit_nsm_steps_reason_for_claim_path(claim.id)

    check 'Enhanced rates claimed'
    check 'Extradition'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      reasons_for_claim: %w[enhanced_rates_claimed extradition],
    )
  end
end
