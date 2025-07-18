require 'system_helper'

RSpec.describe 'Prior authority applications, sent back for info correction - check your answers' do
  before do
    visit provider_entra_id_omniauth_callback_path
    visit prior_authority_steps_check_answers_path(application)
    allow(SubmitToAppStore).to receive(:perform_later)
  end

  let(:application) do
    create(:prior_authority_application, :full,
           :sent_back_for_incorrect_info,
           information_requested: 'Please correct the following information...')
  end

  context 'Application has not been updated' do
    before do
      allow(PriorAuthority::ChangeLister).to receive(:call).and_return([])
    end

    it 'renders a custom govuk error when no changes made since it was sent back by caseworker' do
      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'
      click_on 'Accept and send'

      within('.govuk-error-summary') do
        expect(page).to have_link('Your application needs existing information corrected',
                                  href: '#prior-authority-steps-check-answers-form-base-field-error')
      end

      within('.govuk-form-group--error') do
        expect(page).to have_css('#prior-authority-steps-check-answers-form-base-field-error.govuk-error-message',
                                 text: 'Your application needs existing information corrected')
      end
    end
  end

  context 'Application has been updated' do
    before do
      allow(PriorAuthority::ChangeLister).to receive(:call).and_return(['client_details'])
      stub_request(:put, "https://app-store.example.com/v1/application/#{application.id}").to_return(
        status: 201, body: { application_state: 'provider_updated' }.to_json
      )
    end

    it 'shows the "incorrect information" details from the caseworker' do
      expect(page)
        .to have_content('Your application needs existing information corrected', count: 1)
        .and have_content('Please correct the following information...', count: 1)
    end

    it 'submits when changes made since it was sent back by caseworker', :stub_oauth_token do
      application.defendant.update!(first_name: 'Billy')
      application.update(alternative_quotes_still_to_add: false)

      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'
      click_on 'Accept and send'

      expect(page)
        .to have_title('Application complete')
        .and have_content('What happens next')
    end

    it 'does not submit when changes leave an incomplete section', :stub_oauth_token do
      application.defendant.update!(first_name: nil)
      application.update(alternative_quotes_still_to_add: false)

      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'
      click_on 'Accept and send'

      expect(page).to have_text('1 section needs amending: Client details')
    end

    it 'does not submit when changes leaves multiple incomplete sections', :stub_oauth_token do
      application.defendant.update!(first_name: nil)
      application.primary_quote.update!(organisation: nil)

      application.update(alternative_quotes_still_to_add: false)

      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'
      click_on 'Accept and send'

      expect(page).to have_text('2 sections need amending: Client details, Primary quote')
    end

    it 'does not submit when changes leave incomplete sections and still validates form', :stub_oauth_token do
      application.defendant.update!(first_name: nil)
      application.update(alternative_quotes_still_to_add: false)

      click_on 'Accept and send'

      expect(page)
        .to have_text('1 section needs amending: Client details')
        .and have_text('There is a problem on this page')
        .and have_text('Select if you confirm that all costs are exclusive of VAT')
    end
  end
end
