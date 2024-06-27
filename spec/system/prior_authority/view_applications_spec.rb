require 'rails_helper'

RSpec.describe 'View reviewed applications' do
  let(:arbitrary_fixed_date) { DateTime.new(2024, 3, 22, 15, 23, 11) }

  before do
    travel_to arbitrary_fixed_date
    visit provider_saml_omniauth_callback_path
    application
    visit prior_authority_applications_path
    click_on application.ufn
  end

  context 'when application has been rejected' do
    let(:application) do
      create(:prior_authority_application,
             :full,
             status: 'rejected',
             app_store_updated_at: 1.day.ago,
             assessment_comment: 'You used the wrong form')
    end

    it 'shows rejection details' do
      expect(page).to have_content 'Rejected'
      expect(page).to have_content '£155.00 requested'
      expect(page).to have_content '£0.00 allowed'
      expect(page).to have_content 'You used the wrong form'
      expect(page).to have_content 'If you want to appeal the rejection, email CRM4appeal@justice.gov.uk'
    end
  end

  context 'when application has been granted' do
    let(:application) do
      create(:prior_authority_application,
             :full,
             status: 'granted',
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
             status: 'part_grant',
             assessment_comment: assessment_comment,
             app_store_updated_at: 1.day.ago,
             quotes: [quote],
             additional_costs: [additional_cost])
    end
    let(:assessment_comment) { 'Too much' }

    let(:quote) do
      build(:quote, :primary,
            service_adjustment_comment: 'Too much',
            travel_adjustment_comment: 'Not enough',
            base_cost_allowed: 29,
            travel_cost_allowed: 126)
    end

    let(:additional_cost) do
      build(:additional_cost, :per_item,
            adjustment_comment: 'Nearly right',
            total_cost_allowed: 119)
    end

    it 'shows overall details' do
      expect(page).to have_content 'Part granted'
      expect(page).to have_content '£175.00 requested'
      expect(page).to have_content '£274.00 allowed'
      expect(page).to have_content 'Review service cost adjustments'
      expect(page).to have_content 'Review travel cost adjustments'
      expect(page).to have_content 'Review additional cost adjustments'
      expect(page).to have_content 'If you want to appeal the adjustment, email CRM4appeal@justice.gov.uk'
    end

    it 'shows service cost adjustments' do
      expect(page).to have_content 'Too much'
      expect(page).to have_content '£30.00 £29.00'
    end

    it 'shows travel cost adjustments' do
      expect(page).to have_content 'Not enough'
      expect(page).to have_content '£125.00 £126.00'
    end

    it 'shows additional cost adjustments' do
      expect(page).to have_content 'Nearly right'
      expect(page).to have_content '£20.00 £119.00'
    end

    context 'when no assessment comment exists (part-grant)' do
      let(:assessment_comment) { nil }

      it 'shows overall details' do
        expect(page).to have_content 'Part granted'
        expect(page).to have_content '£175.00 requested'
        expect(page).to have_content '£274.00 allowed'
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
             status: 'sent_back',
             app_store_updated_at: 1.day.ago,
             resubmission_requested: 1.day.ago,
             resubmission_deadline: 12.days.from_now)
    end

    it 'shows expiry details' do
      expect(page).to have_content 'Update needed'
      expect(page).to have_content '£155.00 requested'
      expect(page).to have_content 'Review the requests and resubmit your application by 3 April 2024'
    end
  end

  context 'when application is expired' do
    let(:application) do
      create(:prior_authority_application,
             :full,
             status: 'expired',
             app_store_updated_at: 1.day.ago,
             resubmission_requested: 14.days.ago,
             resubmission_deadline: 1.day.ago)
    end

    it 'shows expiry details' do
      expect(page).to have_content('Expired')
        .and have_content('£155.00 requested')
        .and have_content('On 8 March 2024 we asked you to update your application')
        .and have_content('This was due by 21 March 2024')
    end
  end

  context 'when application is provider updated' do
    let(:application) do
      create(:prior_authority_application,
             :full,
             status: 'provider_updated',
             further_informations: [further_information])
    end

    let(:further_information) do
      build(:further_information,
            information_requested: 'Tell me more',
            information_supplied: 'More info',
            created_at: 1.day.ago,
            supporting_documents: [build(:supporting_document, file_name: 'evidence.pdf')])
    end

    it 'shows uodate details' do
      expect(page).to have_content('Resubmitted')
        .and have_content('Further information request 21 March 2024')
        .and have_content('Tell me more')
        .and have_content('More info')
    end

    it 'lets me download my uploaded file' do
      click_on 'evidence.pdf'
      expect(page).to have_current_path(%r{/test_path})
    end
  end
end
