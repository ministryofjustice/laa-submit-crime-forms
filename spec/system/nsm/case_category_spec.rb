require 'rails_helper'

RSpec.describe 'User can fill in case category', type: :system do
  let(:claim) { create(:claim, claim_type:, youth_court:) }
  let(:claim_type) { 'non_standard_magistrate' }
  let(:youth_court) { 'yes' }

  before do
    visit provider_saml_omniauth_callback_path
    visit edit_nsm_steps_case_category_path(claim.id)
  end

  it 'can do green path' do
    choose 'Category 1A'

    click_on 'Save and continue'

    expect(claim.reload).to have_attributes(
      plea_category: PleaCategory::CATEGORY_1A.value.to_s,
    )
  end

  context 'plea category is not populated' do
    let(:claim) { create(:claim, claim_type: claim_type, youth_court: youth_court, plea_category: nil) }

    it 'shows error message' do
      click_on 'Save and continue'
      expect(page).to have_content('Select the case category')
    end
  end
end
