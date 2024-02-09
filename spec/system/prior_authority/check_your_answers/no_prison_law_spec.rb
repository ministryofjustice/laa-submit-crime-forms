require 'system_helper'

RSpec.describe 'Prior authority applications, no prison law - check your answers' do
  before do
    fill_in_until_step(:submit_application)
    click_on 'Submit application'
  end

  it 'has the expected page title and group headings' do
    expect(page).to have_title('Check your answers')

    expect(page)
      .to have_no_css('.govuk-heading-l', text: 'Application details')
      .and have_css('.govuk-heading-l', text: 'Contact details')
      .and have_css('.govuk-heading-l', text: 'About the case')
      .and have_css('.govuk-heading-l', text: 'About the request')
      .and have_css('.govuk-heading-l', text: 'Required further information')
  end

  it 'shows the application details card' do
    within('.govuk-summary-card', text: 'Application details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Prison lawNo')
        .and have_css('.govuk-summary-card__content', text: 'LAA reference')
        .and have_css('.govuk-summary-card__content', text: 'Unique file number111111/123')

      click_on 'Change'
      expect(page).to have_title('Unique file number')
    end
  end

  it 'shows the case contact card' do
    within('.govuk-summary-card', text: 'Case contact') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Contact detailsJohn Doejohn@does.com')
        .and have_css('.govuk-summary-card__content', text: 'Firm detailsLegalCorp LtdA12345')

      click_on 'Change'
      expect(page).to have_title('Case contact')
    end
  end

  it 'shows the client details card' do
    within('.govuk-summary-card', text: 'Client details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Client nameJohn Doe')
        .and have_css('.govuk-summary-card__content', text: 'Date of birth27 December 2000')

      click_on 'Change'
      expect(page).to have_title('Client details')
    end
  end

  it 'shows the case details card' do
    within('.govuk-summary-card', text: 'Case details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Main offenceSupply a controlled drug of Class A - Heroin')
        .and have_css('.govuk-summary-card__content', text: 'Date of representation order27 December 2023')
        .and have_css('.govuk-summary-card__content', text: 'MAAT number123456')
        .and have_css('.govuk-summary-card__content', text: 'Client detainedNo')
        .and have_css('.govuk-summary-card__content', text: 'Subject to POCAYes')

      click_on 'Change'
      expect(page).to have_title('Case details')
    end
  end

  it 'shows the hearing details card' do
    within('.govuk-summary-card', text: 'Hearing details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: "Date of next hearing#{Date.tomorrow.to_fs(:stamp)}")
        .and have_css('.govuk-summary-card__content', text: 'Likely or actual pleaNot guilty')
        .and have_css('.govuk-summary-card__content', text: "Court typeMagistrates' court")
        .and have_css('.govuk-summary-card__content', text: 'Youth court matterNo')

      click_on 'Change'
      expect(page).to have_title('Hearing details')
    end
  end

  it 'shows the primary quote card' do
    within('.govuk-summary-card', text: 'Primary quote') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Service requiredMeteorologist')
        .and have_css('.govuk-summary-card__content', text: 'Service detailsJoe BloggsLAA, CR0 1RE')
        .and have_css('.govuk-summary-card__content', text: 'Quote uploadTODO')
        .and have_css('.govuk-summary-card__content', text: 'Existing prior authority grantedYes')
        .and have_css('.govuk-summary-card__content', text: 'Why travel costs are requiredClient lives in Wales')
      # TODO: quote sumary

      click_on 'Change'
      expect(page).to have_title('Primary quote summary')
    end
  end

  it 'shows the reason for prior authority card' do
    within('.govuk-summary-card', text: 'Reason for prior authority') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Why prior authority is requiredRequired because...')
      # TODO: supporting document upload file names

      click_on 'Change'
      expect(page).to have_title('Why is prior authority required')
    end
  end
end
