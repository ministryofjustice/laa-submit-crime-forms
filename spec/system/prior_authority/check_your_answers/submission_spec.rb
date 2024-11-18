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

  it 'allows me to go back to the tasklist' do
    click_on 'Back'
    expect(page).to have_title('Your application progress')
  end

  it 'allows me to save and come back later' do
    click_on 'Save and come back later'

    expect(page).to have_title('Your applications')
  end

  context 'when I have confirmed conditions I must abide by', :stub_oauth_token do
    before do
      check 'I confirm that all costs are exclusive of VAT'
      check 'I confirm that any travel expenditure (such as mileage, ' \
            'parking and travel fares) is included as additional items ' \
            'in the primary quote, and is not included as part of any hourly rate'
    end

    context 'when app store succeeds' do
      let(:job) { instance_double(SubmitToAppStore, perform: true) }

      before do
        allow(SubmitToAppStore).to receive(:new).and_return(job)
        click_on 'Accept and send'
      end

      it 'allows me to submit my application' do
        expect(page).to have_title('Application complete')
        expect(job).to have_received(:perform)
        expect(PriorAuthorityApplication.last).to be_submitted
      end

      it 'can be seen on the list of submitted applications' do
        visit submitted_prior_authority_applications_path

        expect(page).to have_title('Your applications')
        expect(page).to have_css('.govuk-table__row', text: '111111/123')
      end

      it 'stops me getting back to the check your answers page' do
        application = PriorAuthorityApplication.find_by(ufn: '111111/123')
        visit prior_authority_steps_check_answers_path(application)

        expect(page).to have_title('Application details')
      end
    end

    context 'when the app store fails' do
      before do
        stub_request(:post, 'https://app-store.example.com/v1/application/').to_return(status: 500)
      end

      it 'shows an error message' do
        application = PriorAuthorityApplication.last
        expect do
          click_on 'Accept and send'
        end.to raise_error "Unexpected response from AppStore - status 500 for '#{application.id}'"
        expect(application.reload).to be_draft
      end
    end

    context 'when the app store autogrants' do
      before do
        stub_request(:post, 'https://app-store.example.com/v1/application/').to_return(status: 201, body: {
          application_state: 'auto_grant',
          application_type: 'crm4',
          last_updated_at: DateTime.current,
          application: {},
        }.to_json)
      end

      it 'records the autogrant' do
        click_on 'Accept and send'
        expect(page).to have_title('Application complete')
        expect(PriorAuthorityApplication.last).to be_auto_grant
      end
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
end
