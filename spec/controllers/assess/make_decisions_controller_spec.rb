require 'rails_helper'

RSpec.describe Assess::MakeDecisionsController do
  let(:caseworker) { create(:caseworker) }

  context 'edit' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:decision) { instance_double(Assess::MakeDecisionForm) }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::MakeDecisionForm).to receive(:new).and_return(decision)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, decision: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:decision) { instance_double(Assess::MakeDecisionForm, save: save, state: 'granted') }
    let(:caseworker) { instance_double(User, role: 'caseworker') }
    let(:claim) { instance_double(SubmittedClaim, id: SecureRandom.uuid) }
    let(:laa_reference_class) { instance_double(Assess::V1::LaaReference, laa_reference: 'AAA111') }
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(caseworker)
      allow(Assess::MakeDecisionForm).to receive(:new).and_return(decision)
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive(:build).and_return(laa_reference_class)
    end

    it 'builds a decision object' do
      put :update, params: {
        claim_id: claim.id,
        assess_make_decision_form: { state: 'granted', partial_comment: nil, reject_comment: nil, id: claim.id }
      }
      expect(Assess::MakeDecisionForm).to have_received(:new).with(
        'state' => 'granted',
        'partial_comment' => '',
        'reject_comment' => '',
        :claim => claim,
        'current_user' => caseworker
      )
    end

    context 'when decision is updated' do
      it 'redirects to claim page' do
        put :update, params: {
          claim_id: claim.id,
          assess_make_decision_form: { state: 'granted', partial_comment: nil, reject_comment: nil, id: claim.id }
        }

        expect(response).to redirect_to(assess_assessed_claims_path)
        expect(flash[:success]).to eq(
          %(You granted this claim <a class="govuk-link" href="/assess/claims/#{claim.id}/claim_details">AAA111</a>)
        )
      end
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          assess_make_decision_form: { state: 'granted', partial_comment: nil, reject_comment: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, decision: })
      end
    end
  end
end
