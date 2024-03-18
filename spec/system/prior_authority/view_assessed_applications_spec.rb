require 'rails_helper'

RSpec.describe 'View assessed applications' do
  before do
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
      expect(page).to have_content 'How to appeal this decision'
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
             app_store_updated_at: 1.day.ago,
             quotes: [quote],
             additional_costs: [additional_cost])
    end

    let(:quote) do
      build(:quote, :primary,
            service_adjustment_comment: 'Too much',
            travel_adjustment_comment: 'Not enough',
            base_cost_allowed: 29,
            travel_cost_allowed: 126)
    end

    let(:additional_cost) do
      build(:additional_cost,
            adjustment_comment: 'Nearly right',
            total_cost_allowed: 119)
    end

    it 'shows overall details' do
      expect(page).to have_content 'Part granted'
      expect(page).to have_content '£275.00 requested'
      expect(page).to have_content '£274.00 allowed'
      expect(page).to have_content 'Review LAA service cost adjustments'
      expect(page).to have_content 'Review LAA travel cost adjustments'
      expect(page).to have_content 'Review LAA additional cost adjustments'
      expect(page).to have_content 'How to appeal this decision'
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
      expect(page).to have_content '£120.00 £119.00'
    end
  end
end
