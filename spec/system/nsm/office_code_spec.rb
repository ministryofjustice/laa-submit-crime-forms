require 'rails_helper'

RSpec.describe 'Office code selection', type: :system do
  let(:office_code_question) { 'Which firm office account number is this claim for?' }
  let(:provider) { Provider.first }

  before do
    visit provider_saml_omniauth_callback_path
    provider.update(office_codes:)
    allow(ActiveOfficeCodeService).to receive(:call).with(office_codes).and_return(office_codes)
    visit edit_nsm_steps_claim_type_path(claim.id)
  end

  context 'when I complete claim type screen as NSM' do
    before do
      fill_in 'What is your unique file number (UFN)?', with: '121212/001'
      choose "Non-standard magistrates' court payment"
      within('.govuk-radios__conditional', text: 'Representation order date') do
        fill_in 'Day', with: '01'
        fill_in 'Month', with: '02'
        fill_in 'Year', with: '2003'
      end

      click_on 'Save and continue'
    end

    context 'when the provider has multiple office codes' do
      let(:claim) do
        create(:claim, office_code: nil, submitter: provider, defendants: defendants, claim_type: :breach_of_injunction)
      end
      let(:defendants) { [] }
      let(:office_codes) { %w[1A123B 1K022G] }

      it 'prompts me to choose an office code' do
        expect(page).to have_content office_code_question
      end

      it "validates if I don't make a selection" do
        click_on 'Save and continue'
        expect(page).to have_content 'Select your firm office account number'
      end

      it 'Saves my choice' do
        choose '1A123B'
        click_on 'Save and continue'
        expect(page).to have_content 'Was this case worked on in an office in an undesignated area?'
        expect(claim.reload.office_code).to eq '1A123B'
      end
    end

    context 'when provider has a single office code that has been pre-selected' do
      let(:claim) { create(:claim, office_code: '1A123B', submitter: provider) }
      let(:office_codes) { %w[1A123B] }

      it 'skips the office code screen and goes straight to office area' do
        expect(page).to have_content 'Was this case worked on in an office in an undesignated area?'
      end
    end
  end

  context 'when I complete claim type screen as BOI' do
    before do
      fill_in 'What is your unique file number (UFN)?', with: '121212/001'
      choose 'Breach of injunction'
      fill_in 'Clients CNTP (contempt) number', with: 'CNTP1234'
      within('.govuk-radios__conditional', text: 'Date the CNTP rep order was issued') do
        fill_in 'Day', with: '01'
        fill_in 'Month', with: '02'
        fill_in 'Year', with: '2003'
      end

      click_on 'Save and continue'
    end

    context 'when the provider has multiple office codes' do
      let(:claim) { create(:claim, office_code: nil, submitter: provider, defendants: defendants) }
      let(:defendants) { [] }
      let(:office_codes) { %w[1A123B 1K022G] }

      it 'saves my answer and forwards me on to the task list' do
        choose '1A123B'
        click_on 'Save and continue'
        expect(page).to have_content 'Your claim progress'
        expect(claim.reload.office_code).to eq '1A123B'
      end
    end

    context 'when provider has a single office code that has been pre-selected' do
      let(:claim) { create(:claim, office_code: '1A123B', submitter: provider) }
      let(:office_codes) { %w[1A123B] }

      it 'skips the office code screen and goes straight to task list' do
        expect(page).to have_content 'Your claim progress'
      end
    end
  end
end
