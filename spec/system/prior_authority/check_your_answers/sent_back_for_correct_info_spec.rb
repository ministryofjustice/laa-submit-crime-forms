require 'system_helper'

RSpec.describe 'Prior authority applications, sent back for info correction - check your answers' do
  before do
    visit provider_saml_omniauth_callback_path
    visit prior_authority_steps_check_answers_path(application)
    allow(SubmitToAppStore).to receive(:perform_later)
  end

  let(:application) { create(:prior_authority_application, :full, :sent_back_for_incorrect_info) }

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
      allow(PriorAuthority::ChangeLister).to receive(:call).and_return([true])
    end

    it 'shows the "incorrect information" details from the caseworker' do
      expect(page)
        .to have_content('Your application needs existing information corrected', count: 1)
        .and have_content('Please correct the following information...', count: 1)
    end

    it 'submits when changes made since it was sent back by caseworker', :stub_oauth_token do
      application.defendant.update!(first_name: 'Billy')

      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'
      click_on 'Accept and send'

      expect(page)
        .to have_title('Application complete')
        .and have_content('What happens next')
    end
  end
end
