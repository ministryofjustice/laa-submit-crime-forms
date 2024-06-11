require 'system_helper'

RSpec.describe 'Mileage and Other disbursement cost conditional fields', :javascript, type: :system do
  before do
    visit provider_saml_omniauth_callback_path
    click_link 'Accept analytics cookies'

    visit edit_nsm_steps_disbursement_cost_path(id: claim, disbursement_id: disbursement.id)
  end

  let(:disbursement) do
    create(:disbursement,
           disbursement_type: disbursement_type,
           disbursement_date: 1.month.ago.to_date,
           claim: claim)
  end

  let(:claim) { create(:claim) }
  let(:disbursement_type) { DisbursementTypes::CAR.to_s }

  it 'displays the expected title' do
    expect(page).to have_title('Disbursement cost')
  end

  context 'With a "mileage" type disbursement' do
    let(:disbursement_type) { DisbursementTypes::CAR.to_s }

    it 'displays the mileage field' do
      expect(page).to have_field('Number of miles')
    end

    it 'hides the prior authority question' do
      expect(page).to have_no_content('Have you been granted prior authority')
    end
  end

  context 'With an "other" type disbursement' do
    let(:disbursement_type) { DisbursementTypes::OTHER.to_s }

    it 'hides mileage field' do
      expect(page).to have_no_field('Number of miles')
    end

    it 'displays prior authority question' do
      expect(page).to have_content('Have you been granted prior authority for this disbursement?')
    end
  end
end
