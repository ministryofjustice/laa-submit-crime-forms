require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::PrimaryQuote, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { create(:prior_authority_application, primary_quote:, service_type:, prior_authority_granted:) }
  let(:primary_quote) { nil }
  let(:service_type) { 'meteorologist' }
  let(:prior_authority_granted) { true }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/primary_quote") }

    context 'when quote is complete (with travel expenses)' do
      let(:primary_quote) { build(:quote) }

      it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/primary_quote_summary") }
    end

    context 'when quote is complete (without travel expenses)' do
      let(:primary_quote) { build(:quote, travel_cost_reason: nil, travel_cost_per_hour: nil, travel_time: nil) }

      it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/primary_quote_summary") }
    end

    context 'when travel expense reason is missing (and non-prison law and not detained)' do
      let(:primary_quote) { build(:quote, travel_cost_reason: nil) }

      it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/travel_detail") }
    end
  end
end
