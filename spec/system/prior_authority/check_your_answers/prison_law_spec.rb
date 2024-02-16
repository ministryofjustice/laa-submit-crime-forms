require 'system_helper'

# NOTE: see non_prison_law_spec system test for main flow. This only checks the differences.
#
RSpec.describe 'Prior authority applications, prison law - check your answers' do
  before do
    fill_in_until_step(:submit_application, prison_law: 'Yes')
    click_on 'Submit application'
  end

  it 'shows the Case and hearing details card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Case and hearing details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Date of next hearingNot known')

      click_on 'Change'
      expect(page).to have_title('Case and hearing details')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'does NOT show the Case details and Hearing details cards' do
    expect(page)
      .to have_no_css('.govuk-summary-card', text: 'Case details')
      .and have_no_css('.govuk-summary-card', text: 'Hearing details')
  end
end
