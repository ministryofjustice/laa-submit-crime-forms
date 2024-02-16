require 'system_helper'

RSpec.describe 'Prior authority applications, check your answers, submission' do
  before do
    fill_in_until_step(:submit_application)
    click_on 'Submit application'
  end

  it 'has the expected content relating to submission' do
    expect(page).to have_title('Check your answers')

    expect(page)
      .to have_css('.govuk-heading-l', text: 'Now send your application')
      .and have_css(
        '.govuk-body',
        text: 'By submitting this application you are confirming that, ' \
              'to the best of your knowledge, the details you are providing are correct.'
      )
  end

  it 'allows me to save and come back later' do
    click_on 'Save and come back later'

    expect(page).to have_title('Your applications')
  end

  context 'when I have confirmed conditions I must abide by' do
    it 'allows me to submit my application' do
      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'

      click_on 'Accept and send'
      expect(page).to have_title('Application complete')
    end
  end

  context 'when I have NOT confirmed conditions I must abide by' do
    it 'warns me to confirm the conditions' do
      click_on 'Accept and send'
      expect(page).to have_title('Check your answers')
        .and have_css('.govuk-error-summary', text: 'There is a problem on this page')
        .and have_css('.govuk-error-message', text: 'Select if you confirm that', count: 2)
    end
  end

  context 'when check answers form already submitted' do
    before do
      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'

      click_on 'Accept and send'
    end

    it 'can be seen on the list of submitted applications' do
      visit prior_authority_applications_path(anchor: 'submitted')

      expect(page).to have_title('Your applications')
      expect(page).to have_css('.govuk-table__row', text: '111111/123')
    end

    it 'stops me getting back to the check your answers page' do
      application = PriorAuthorityApplication.find_by(ufn: '111111/123')
      visit prior_authority_steps_check_answers_path(application)

      expect(page).to have_title('Your application progress')
    end
  end
end
