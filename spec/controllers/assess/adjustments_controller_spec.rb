require 'rails_helper'

RSpec.describe Assess::AdjustmentsController do
  context 'show' do
    let(:caseworker) { create(:caseworker) }
    let(:claim) { instance_double(SubmittedClaim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:claim_summary) { instance_double(Assess::V1::ClaimSummary) }
    let(:core_cost_summary) { instance_double(Assess::V1::CoreCostSummary) }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive(:build).with(:claim_summary, claim).and_return(claim_summary)
      allow(Assess::BaseViewModel).to receive(:build).with(:core_cost_summary, claim).and_return(core_cost_summary)
    end

    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(SubmittedClaim).to have_received(:find).with(claim_id)
      expect(Assess::BaseViewModel).to have_received(:build).with(:claim_summary, claim)
      expect(Assess::BaseViewModel).to have_received(:build).with(:core_cost_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim:, claim_summary:, core_cost_summary: })
      expect(response).to be_successful
    end
  end
end
