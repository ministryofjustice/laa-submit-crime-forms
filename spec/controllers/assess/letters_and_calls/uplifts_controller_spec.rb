require 'rails_helper'

RSpec.describe Assess::LettersAndCalls::UpliftsController do
  let(:caseworker) { create(:caseworker) }

  context 'edit' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Assess::Uplift::LettersAndCallsForm) }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::Uplift::LettersAndCallsForm).to receive(:new).and_return(form)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, form: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Assess::Uplift::LettersAndCallsForm, save:) }

    before do
      allow(Assess::Uplift::LettersAndCallsForm).to receive(:new).and_return(form)
      allow(SubmittedClaim).to receive(:find).and_return(claim)
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        put :update, params: { claim_id: claim_id, assess_uplift_letters_and_calls_form: { some: :data } }

        expect(controller).to redirect_to(assess_claim_adjustments_path(claim, anchor: 'letters-and-calls-tab'))
        expect(response).to have_http_status(:found)
      end
    end

    context 'when form save is unsuccessful' do
      let(:save) { false }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        put :update, params: { claim_id: claim_id, assess_uplift_letters_and_calls_form: { some: :data } }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, form: })
        expect(response).to be_successful
      end
    end
  end
end
