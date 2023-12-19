require 'rails_helper'

RSpec.describe 'Supporting Evidence' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:submitted_claim) }

  before do
    sign_in user
    visit assess_claim_supporting_evidences_path(claim)
  end

  context 'There is supporting evidence and nothing is sent by post' do
    it 'can view supporting evidence table' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_content(
          'Advocacy evidence _ Tom_TC.pdf' \
          'Monday18 September 2023'
        )
      end
    end

    it 'has a link to download the file' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_link('Advocacy evidence _ Tom_TC.pdf', href: /test.s3.us-stubbed-1.amazonaws.com/)
      end
    end

    it 'no send by post info shown' do
      expect(page).not_to have_content('The provider has chosen to post the evidence to:')
    end
  end

  context 'There is supporting evidence and some evidence is sent by post' do
    let(:claim) { create(:submitted_claim, send_by_post: true) }

    it 'can view supporting evidence table' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_content(
          'Advocacy evidence _ Tom_TC.pdf' \
          'Monday18 September 2023'
        )
      end
    end

    it 'has a link to download the file' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_link('Advocacy evidence _ Tom_TC.pdf', href: /test.s3.us-stubbed-1.amazonaws.com/)
      end
    end

    it 'send by post info is shown' do
      expect(page).to have_content('The provider has chosen to post the evidence to:')
    end
  end

  context 'There is supporting evidence sent by post' do
    let(:claim) { create(:submitted_claim, send_by_post: true, supporting_evidences: []) }

    it 'supporting evidence table not shown' do
      expect(page).not_to have_css('.govuk-table__row')
    end

    it 'send by post info is shown' do
      expect(page).to have_content('The provider has chosen to post the evidence to:')
    end
  end
end
