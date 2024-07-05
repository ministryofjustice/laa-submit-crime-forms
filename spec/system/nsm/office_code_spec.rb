require 'rails_helper'

RSpec.describe 'Office code selection', type: :system do
  let(:office_code_question) { 'Which firm account number is this claim for?' }
  let(:provider) { Provider.first }

  context 'when I complete the firm details screen' do
    before do
      visit provider_saml_omniauth_callback_path
      provider.update(office_codes:)
      visit edit_nsm_steps_firm_details_path(claim.id)
      fill_in 'Firm name', with: 'Lawyers'
      fill_in 'Address line 1', with: 'home'
      fill_in 'Town or city', with: 'hometown'
      fill_in 'Postcode', with: 'AA1 1AA'

      choose 'nsm-steps-firm-details-form-firm-office-attributes-vat-registered-yes-field'

      fill_in 'Solicitor first name', with: 'James'
      fill_in 'Solicitor last name', with: 'Robert'
      fill_in 'Solicitor reference number', with: '2222'

      choose 'nsm-steps-firm-details-form-solicitor-attributes-alternative-contact-details-yes-field'

      fill_in 'First name of alternative contact', with: 'Jim'
      fill_in 'Last name of alternative contact', with: 'Bob'
      fill_in 'Email address of alternative contact', with: 'jim@bob.com'

      click_on 'Save and continue'
    end

    context 'when the provider has multiple office codes' do
      let(:claim) { create(:claim, office_code: nil, submitter: provider, defendants: defendants) }
      let(:defendants) { [] }
      let(:office_codes) { %w[1A123B 1K022G] }

      it 'prompts me to choose an office code' do
        expect(page).to have_content office_code_question
      end

      it "validates if I don't make a selection" do
        click_on 'Save and continue'
        expect(page).to have_content 'Select your firm account number'
      end

      it 'Saves my choice' do
        choose '1A123B'
        click_on 'Save and continue'
        expect(page).to have_content 'Defendant details'
        expect(claim.reload.office_code).to eq '1A123B'
      end

      it 'Allows me to save and come back later' do
        click_on 'Save and come back later'
        expect(page.find(:id, 'nsm/firm_details-status').text).to eq 'In progress'
        expect(claim.reload.office_code).to be_nil
      end

      context 'when the claim already has a defendant' do
        let(:defendants) { [build(:defendant, :valid)] }

        it 'Takes me to the defendant summary path' do
          choose '1A123B'
          click_on 'Save and continue'
          expect(page).to have_content 'You added 1 defendant'
        end
      end
    end

    context 'when provider has a single office code that has been pre-selected' do
      let(:claim) { create(:claim, office_code: '1A123B', submitter: provider) }
      let(:office_codes) { %w[1A123B] }

      it 'skips the office code screen' do
        expect(page).to have_no_content office_code_question
      end
    end
  end
end
