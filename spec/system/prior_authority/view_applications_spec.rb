require 'system_helper'

RSpec.describe 'View applications', :stub_oauth_token do
  let(:arbitrary_fixed_date) { DateTime.new(2024, 3, 22, 15, 23, 11) }
  let(:data) do
    data = SubmitToAppStore::PriorAuthorityPayloadBuilder.new(
      application: application,
      include_events: false
    ).payload.merge(last_updated_at: application.app_store_updated_at)
    data[:application][:assessment_comment] = application.assessment_comment
    data
  end

  before do
    travel_to arbitrary_fixed_date
    stub_request(:get, "https://app-store.example.com/v1/application/#{application.id}").to_return(
      status: 200,
      body: data.to_json
    )
    visit provider_saml_omniauth_callback_path
    application
  end

  context 'that are reviewed' do
    before do
      visit prior_authority_application_path(application)
    end

    context 'when application has been rejected' do
      let(:application) do
        create(:prior_authority_application,
               :full,
               :with_further_information_supplied,
               :with_alternative_quotes,
               state: 'rejected',
               app_store_updated_at: 1.day.ago,
               assessment_comment: 'You used the wrong form')
      end

      it 'shows rejection details' do
        expect(page).to have_content 'Rejected'
        expect(page).to have_content '£0.00 allowed'
        expect(page).to have_content 'You used the wrong form'
        expect(page).to have_content 'If you want to appeal the rejection, email CRM4appeal@justice.gov.uk'
      end

      it 'lets me download a PDF' do
        click_on 'Create a printable PDF'
        expect(page).to have_current_path download_prior_authority_application_path(application)
        expect(page.driver.response.headers['Content-Type']).to eq 'application/pdf'
      end
    end

    context 'when application has been granted' do
      let(:application) do
        create(:prior_authority_application,
               :full,
               state: 'granted',
               app_store_updated_at: 1.day.ago)
      end

      it 'shows grant details' do
        expect(page).to have_content 'Granted'
        expect(page).to have_content '£155.00 requested'
        expect(page).to have_content '£155.00 allowed'
      end
    end

    context 'when application has been part-granted with adjustments' do
      let(:application) do
        create(:prior_authority_application,
               :full,
               state: 'part_grant',
               assessment_comment: assessment_comment,
               app_store_updated_at: 1.day.ago,
               quotes: [quote],
               additional_costs: [additional_cost])
      end
      let(:assessment_comment) { 'Too much' }

      let(:quote) do
        build(:quote, :primary,
              service_adjustment_comment: 'Too much',
              travel_adjustment_comment: 'Not enough',)
      end

      let(:additional_cost) do
        build(:additional_cost, :per_item,
              adjustment_comment: 'Nearly right')
      end

      let(:data) do
        data = SubmitToAppStore::PayloadBuilder.call(application).merge(last_updated_at: 1.hour.ago)
        data[:application][:assessment_comment] = application.assessment_comment
        data[:application][:quotes][0][:period_original] = 240
        data[:application][:quotes][0][:adjustment_comment] = quote.service_adjustment_comment
        data[:application][:quotes][0][:travel_cost_per_hour_original] = '75.6'
        data[:application][:quotes][0][:travel_adjustment_comment] = quote.travel_adjustment_comment
        data[:application][:additional_costs][0][:adjustment_comment] = additional_cost.adjustment_comment
        data[:application][:additional_costs][0][:items_original] = 30
        data
      end

      it 'shows overall details' do
        expect(page).to have_content 'Part granted'
        expect(page).to have_content '£529.00 requested'
        expect(page).to have_content '£175.00 allowed'
        expect(page).to have_content 'Review service cost adjustments'
        expect(page).to have_content 'Review travel cost adjustments'
        expect(page).to have_content 'Review additional cost adjustments'
        expect(page).to have_content 'If you want to appeal the adjustment, email CRM4appeal@justice.gov.uk'
      end

      it 'shows service cost adjustments' do
        expect(page).to have_content 'Too much'
        expect(page).to have_content '£40.00 £30.00'
      end

      it 'shows travel cost adjustments' do
        expect(page).to have_content 'Not enough'
        expect(page).to have_content '£189.00 £125.00'
      end

      it 'shows additional cost adjustments' do
        expect(page).to have_content 'Nearly right'
        expect(page).to have_content '£300.00 £20.00'
      end

      context 'when no assessment comment exists (part-grant)' do
        let(:assessment_comment) { nil }

        it 'shows overall details' do
          expect(page).to have_content 'Part granted'
          expect(page).to have_content '£529.00 requested'
          expect(page).to have_content '£175.00 allowed'
          expect(page).to have_content 'Review service cost adjustments'
          expect(page).to have_content 'Review travel cost adjustments'
          expect(page).to have_content 'Review additional cost adjustments'
          expect(page).to have_content 'If you want to appeal the adjustment, email CRM4appeal@justice.gov.uk'
        end
      end
    end

    context 'when application is sent back' do
      let(:application) do
        create(:prior_authority_application,
               :full,
               state: 'sent_back',
               app_store_updated_at: 1.day.ago,
               resubmission_requested: 1.day.ago,
               resubmission_deadline: 12.days.from_now,
               further_informations: [build(:further_information, information_requested: 'Tell me more')],
               incorrect_informations: [build(:incorrect_information, information_requested: 'Fix it')])
      end

      let(:data) do
        application.incorrect_informations.first.update!(sections_changed: [])
        data = SubmitToAppStore::PayloadBuilder.call(application).merge(last_updated_at: application.app_store_updated_at)
        data[:application][:assessment_comment] = application.assessment_comment
        data[:application][:resubmission_requested] = application.resubmission_requested
        data[:application][:resubmission_deadline] = application.resubmission_deadline
        data
      end

      it 'shows send back details' do
        expect(page).to have_content('Update needed')
          .and have_content('£155.00 requested')
          .and have_content('Review the requests and resubmit your application by 3 April 2024')
          .and have_content('Further information request Tell me more')
          .and have_content('Amendment request Fix it')
      end
    end

    context 'when application is expired' do
      let(:application) do
        create(:prior_authority_application,
               :full,
               state: 'expired',
               app_store_updated_at: 1.day.ago,
               resubmission_requested: 14.days.ago,
               resubmission_deadline: 1.day.ago)
      end

      let(:data) do
        data = SubmitToAppStore::PayloadBuilder.call(application).merge(last_updated_at: application.app_store_updated_at)
        data[:application][:assessment_comment] = application.assessment_comment
        data[:application][:further_information] = [{ requested_at: application.resubmission_requested }]
        data[:application][:resubmission_deadline] = application.resubmission_deadline
        data
      end

      it 'shows expiry details' do
        expect(page).to have_content('Expired')
          .and have_content('£155.00 requested')
          .and have_content('On 8 March 2024 we asked you to update your application')
          .and have_content('This was due by 21 March 2024')
      end
    end
  end

  context 'when application does not belong to provider' do
    let(:application) do
      create(:prior_authority_application, :full, state: 'granted', app_store_updated_at: 1.day.ago, office_code: 'QQQQQ')
    end

    it 'shows an error message' do
      visit prior_authority_application_path(application)
      expect(page).to have_content 'not found'
    end
  end

  context 'that are submitted' do
    before do
      visit prior_authority_application_path(application)
    end

    context 'when application is provider updated' do
      let(:application) do
        create(:prior_authority_application,
               :full,
               state: 'provider_updated',
               further_informations: [further_information],
               incorrect_informations: [incorrect_information],
               app_store_updated_at: 1.day.ago)
      end

      let(:further_information) do
        build(:further_information,
              information_requested: 'Tell me more',
              information_supplied: 'More info',
              requested_at: 1.day.ago,
              # the first dash in the below file name in an en dash, which is not a valid ISO-8859-1 character
              supporting_documents: [build(:supporting_document, file_path: 'S3-ID', file_name: 'evidence–with-weird-char.pdf')])
      end

      let(:incorrect_information) do
        build(:incorrect_information,
              information_requested: 'Fix it',
              sections_changed: [:client_detail, :alternative_quote_1],
              created_at: 1.day.ago)
      end

      it 'shows update details' do
        expect(page).to have_content('Resubmitted')
          .and have_content('Further information request 21 March 2024')
          .and have_content('Tell me more')
          .and have_content('More info')
          .and have_content('Fix it')
          .and have_content('Client details and alternative quote 1 amended')
      end

      it 'lets me download my uploaded file' do
        click_on 'evidence–with-weird-char.pdf'
        expect(page).to have_current_path(%r{/S3-ID})
        expect(page.driver.request.params['response-content-disposition']).to eq(
          'attachment; filename="evidencewith-weird-char.pdf"'
        )
      end
    end
  end
end
