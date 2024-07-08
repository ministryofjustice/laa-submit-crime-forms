require 'rails_helper'

RSpec.describe PriorAuthorityApplication do
  subject(:prior_authority_application) do
    create(:prior_authority_application, :with_firm_and_solicitor, :with_created_alternative_quotes,
           :with_created_primary_quote, :with_additional_costs)
  end

  describe '#provider' do
    it 'belongs to a provider' do
      expect(prior_authority_application.provider).to be_a(Provider)
    end
  end

  describe '#solicitor' do
    it 'belongs to a solcitor' do
      expect(prior_authority_application.solicitor).to be_a(Solicitor)
    end
  end

  describe '#firm_office' do
    it 'belongs to a firm_office' do
      expect(prior_authority_application.firm_office).to be_a(FirmOffice)
    end
  end

  describe '#total_cost_gbp' do
    context 'claim has quotes' do
      it 'calculates the total cost and shows it in pounds' do
        expect(prior_authority_application.total_cost_gbp).to eq('£186.67')
      end
    end

    context 'claim has no quotes or additional costs' do
      subject(:prior_authority_application) { create(:prior_authority_application) }

      it 'calculates the total cost and shows it in pounds' do
        expect(prior_authority_application.total_cost_gbp).to be_nil
      end
    end
  end

  describe '#further_information_needed?' do
    context 'a draft application' do
      subject(:prior_authority_application) { create(:prior_authority_application, status: 'draft') }

      it { expect(prior_authority_application).not_to be_further_information_needed }
    end

    context 'a sent back application' do
      subject(:prior_authority_application) do
        create(:prior_authority_application, :with_further_information_request, app_store_updated_at:)
      end

      let(:app_store_updated_at) { DateTime.current - 1.day }

      it { expect(prior_authority_application).to be_further_information_needed }
    end

    context 'a sent back application with no further information' do
      subject(:prior_authority_application)  { create(:prior_authority_application, status: 'sent_back') }

      it { expect(prior_authority_application).not_to be_further_information_needed }
    end
  end
end
