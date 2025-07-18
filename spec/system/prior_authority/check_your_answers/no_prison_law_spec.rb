require 'system_helper'

RSpec.describe 'Prior authority applications, no prison law - check your answers', :stub_oauth_token do
  let(:application) do
    create(:prior_authority_application, :as_draft, :with_complete_non_prison_law)
  end

  before do
    stub_request(:get, "https://app-store.example.com/v1/application/#{application.id}").to_return(
      status: 200,
      body: SubmitToAppStore::PriorAuthorityPayloadBuilder.new(application:).payload.to_json
    )

    visit provider_entra_id_omniauth_callback_path
    visit prior_authority_steps_check_answers_path(application)
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
        .and have_css('.govuk-summary-card__content', text: "LAA reference#{application.laa_reference}")
        .and have_css('.govuk-summary-card__content', text: %r{Unique file number\d{6}/123})

      click_on 'Change'
      expect(page).to have_title('Unique file number')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'shows the case contact card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Case contact') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: /Contact details.*@.*\.com/)
        .and have_css('.govuk-summary-card__content', text: /Firm details.*1A123B/)

      click_on 'Change'
      expect(page).to have_title('Case contact')
    end

    click_on 'Save and continue'
    first('.govuk-radios__label').click
    click_on 'Save and continue'

    expect(page).to have_title('Check your answers')
  end

  it 'shows the client details card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Client details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: /Client name/)
        .and have_css('.govuk-summary-card__content', text: /Date of birth/)

      click_on 'Change'
      expect(page).to have_title('Client details')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end

  it 'shows the case details card and continues to check your answers' do
    within('.govuk-summary-card', text: 'Case details') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: /Main offence/)
        .and have_css('.govuk-summary-card__content', text: /Date of representation order/)
        .and have_css('.govuk-summary-card__content', text: /Client detainedNo/)
        .and have_css('.govuk-summary-card__content', text: /Subject to POCAYes/)

      click_on 'Change'
    end
    expect(page).to have_title('Case details')

    within('.govuk-form-group', text: 'Is this case subject to POCA (Proceeds of Crime Act 2002)?') do
      choose 'No'
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
        .and have_css('.govuk-summary-card__content', text: 'Why not? whatever')
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
        .and have_css('.govuk-summary-card__content', text: 'Crown Court (excluding Central Criminal Court)')
        .and have_no_content('Youth court matter')
        .and have_no_content('Psychiatric liaison service')
        .and have_no_content('Why not?')
    end
  end

  it 'shows the primary quote card' do
    within('.govuk-summary-card', text: 'Primary quote') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: /Service required/)
        .and have_css('.govuk-summary-card__content', text: /Service provider details.*Joe Bloggs/)
        .and have_css('.govuk-summary-card__content', text: 'Quote uploadtest.png')
        .and have_css('.govuk-summary-card__content', text: 'Existing prior authority grantedNo')

      expect(page)
        .to have_css('.govuk-table__caption', text: 'Primary quote summary')

      within('.govuk-table__row', text: 'Total cost') { expect(page).to have_content(/£\d+\.\d{2}/) }

      click_on 'Change'
      expect(page).to have_title('Primary quote summary')
    end
  end

  it 'shows the alternative quote card' do
    within('.govuk-summary-card', text: 'Alternative quotes') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: 'Reason for no alternative quotes')
        .and have_css('.govuk-summary-card__content', text: 'a reason')

      click_on 'Change'
      expect(page).to have_title('Have you got other quotes?')
    end
  end

  it 'shows the reason for prior authority card' do
    within('.govuk-summary-card', text: 'Reason for prior authority') do
      expect(page)
        .to have_css('.govuk-summary-card__content', text: /Why prior authority is required.*something/)

      click_on 'Change'
      expect(page).to have_title('Why is prior authority required')
    end

    click_on 'Save and continue'
    expect(page).to have_title('Check your answers')
  end
end
