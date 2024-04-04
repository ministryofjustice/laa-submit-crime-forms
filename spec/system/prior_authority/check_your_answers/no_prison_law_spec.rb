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
  end

  it 'shows the application details card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Application details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Prison lawNo')
        .and have_css('.govuk-summary-card__content', text: 'LAA reference')
        .and have_css('.govuk-summary-card__content', text: 'Unique file number111111/123')

      click_on 'Change'
      expect(page).to have_title('Unique file number')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'shows the case contact card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Case contact') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Contact detailsJohn Doejohn@does.com')
        .and have_css('.govuk-summary-card__content', text: 'Firm detailsLegalCorp LtdA12345')

      click_on 'Change'
      expect(page).to have_title('Case contact')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'shows the client details card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Client details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Client nameJohn Doe')
        .and have_css('.govuk-summary-card__content', text: 'Date of birth27 December 2000')

      click_on 'Change'
      expect(page).to have_title('Client details')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'shows the case details card and continues to check your answers' do
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

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'shows the hearing details for magistrates\' court card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Hearing details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: "Date of next hearing#{Date.tomorrow.to_fs(:stamp)}")
        .and have_css('.govuk-summary-card__content', text: 'Likely or actual pleaNot guilty')
        .and have_css('.govuk-summary-card__content', text: "Court typeMagistrates' court")
        .and have_css('.govuk-summary-card__content', text: 'Youth court matterNo')

      click_on 'Change'
      expect(page).to have_title('Hearing details')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Is this a youth court matter?')

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'allows change of hearing details to central criminal court card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Hearing details') do
      click_on 'Change'
      expect(page).to have_title('Hearing details')
    end

    choose 'Central Criminal Court'

    click_on 'Save and continue'
    expect(page).to have_title('Have you accessed the psychiatric liaison service?')

    choose 'No'
    fill_in 'Explain why you did not access this service', with: 'whatever'

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')

    within('.govuk-summary-card', text: 'Hearing details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: "Date of next hearing#{Date.tomorrow.to_fs(:stamp)}")
        .and have_css('.govuk-summary-card__content', text: 'Likely or actual pleaNot guilty')
        .and have_css('.govuk-summary-card__content', text: 'Court typeCentral Criminal Court')
        .and have_css('.govuk-summary-card__content', text: 'Psychiatric liaison service accessedNo')
        .and have_css('.govuk-summary-card__content', text: 'Why not?whatever')
    end
  end

  it 'allows change of hearing details to crown court card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Hearing details') do
      click_on 'Change'
      expect(page).to have_title('Hearing details')
    end

    choose 'Crown Court (excluding Central Criminal Court)'

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')

    within('.govuk-summary-card', text: 'Hearing details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: "Date of next hearing#{Date.tomorrow.to_fs(:stamp)}")
        .and have_css('.govuk-summary-card__content', text: 'Likely or actual pleaNot guilty')
        .and have_css('.govuk-summary-card__content', text: 'Court typeCrown Court (excluding Central Criminal Court)')
        .and have_no_content('Youth court matter')
        .and have_no_content('Psychiatric liaison service')
        .and have_no_content('Why not?')
    end
  end

  it 'shows the primary quote card' do
    within('.govuk-summary-card', text: 'Primary quote') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Service requiredMeteorologist')
        .and have_css('.govuk-summary-card__content', text: 'Service provider detailsJoe BloggsLAA, CR0 1RE')
        .and have_css('.govuk-summary-card__content', text: 'Quote uploadtest.png')
        .and have_css('.govuk-summary-card__content', text: 'Existing prior authority grantedYes')
        .and have_css('.govuk-summary-card__content', text: /Why travel costs are required.*Client lives in Wales/)

      expect(page)
        .to have_css('.govuk-table__caption', text: 'Primary quote summary')

      within('.govuk-table__row', text: 'Service') { expect(page).to have_content('£6.15') }
      within('.govuk-table__row', text: 'Travel') { expect(page).to have_content('£1.61') }
      within('.govuk-table__row', text: 'Additional') { expect(page).to have_content('£0.00') }
      within('.govuk-table__row', text: 'Total cost') { expect(page).to have_content('£7.76') }

      click_on 'Change'
      expect(page).to have_title('Primary quote summary')
    end
  end

  it 'shows the alternative quote card' do
    within('.govuk-summary-card', text: 'Alternative quotes') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Quote 1Jim Bob£155.00')

      click_on 'Change'
      expect(page).to have_title('You\'ve added 1 alternative quote')
    end
  end

  it 'shows the reason for prior authority card' do
    within('.govuk-summary-card', text: 'Reason for prior authority') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: /Why prior authority is required.*Required because.../)
      # TODO: supporting document upload file names

      click_on 'Change'
      expect(page).to have_title('Why is prior authority required')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end
end
