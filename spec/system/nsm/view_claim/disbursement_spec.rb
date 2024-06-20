require 'system_helper'

RSpec.describe 'View disbursement after submission', :javascript, type: :system do
  before do
    visit provider_saml_omniauth_callback_path
    click_link 'Accept analytics cookies'

    visit item_nsm_steps_view_claim_path(id: claim, item_type: 'disbursement', item_id: disbursement.id)
  end

  let(:some_date) { 1.month.ago.to_date }
  let(:claim) { create(:claim) }

  context 'With a "mileage" type disbursement' do
    let(:disbursement) do
      create(:disbursement,
             disbursement_type: DisbursementTypes::CAR.to_s,
             other_type: nil,
             disbursement_date: some_date,
             details: 'I need it...',
             miles: 101,
             apply_vat: 'true',
             claim: claim)
    end

    it 'displays the expected title' do
      expect(page).to have_title('Claim details')
    end

    it 'displays the expected h1' do
      expect(page).to have_css('h1', text: 'Car mileage')
    end

    it 'displays the expected table caption' do
      expect(page).to have_css('caption', text: 'Your claimed costs')
    end

    it 'displays the expected details for the disbursement' do
      expect(page)
        .to have_content("Date #{some_date.to_fs(:stamp)}")
        .and have_content('Disbursement type Car mileage')
        .and have_content('Disbursement description I need it')
        .and have_content('Mileage 101 miles')
        .and have_content('Net cost £45.45')
        .and have_content('VAT £9.09')
        .and have_content('Total cost £54.54')
    end

    it 'does not display the prior authority question and answer' do
      expect(page).to have_no_content('Prior authority granted?')
    end
  end

  context 'With an "other" type disbursement' do
    let(:disbursement) do
      create(:disbursement,
             disbursement_type: DisbursementTypes::OTHER.to_s,
             other_type: 'accident_reconstruction_report',
             disbursement_date: some_date,
             prior_authority: 'yes',
             details: 'I need it...',
             miles: nil,
             total_cost_without_vat: 90.10,
             apply_vat: 'true',
             claim: claim)
    end

    it 'displays the expected title' do
      expect(page).to have_title('Claim details')
    end

    it 'displays the expected h1' do
      expect(page).to have_css('h1', text: 'Accident Reconstruction Report')
    end

    it 'displays the expected table caption' do
      expect(page).to have_css('caption', text: 'Your claimed costs')
    end

    it 'displays the expected details for the disbursement' do
      expect(page)
        .to have_content("Date #{some_date.to_fs(:stamp)}")
        .and have_content('Disbursement type Accident Reconstruction Report')
        .and have_content('Disbursement description I need it')
        .and have_content('Prior authority granted? Yes')
        .and have_content('Net cost £90.10')
        .and have_content('VAT £18.02')
        .and have_content('Total cost £108.12')
    end

    it 'does not display the mileage question and answer' do
      expect(page).to have_no_content('Mileage')
    end
  end
end
