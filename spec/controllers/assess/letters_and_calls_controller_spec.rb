require 'rails_helper'

RSpec.describe Assess::LettersAndCallsController do
  let(:caseworker) { create(:caseworker) }

  describe '#index' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:letters_and_calls) { instance_double(Assess::V1::LettersAndCallsSummary) }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive_messages(build: letters_and_calls)
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(SubmittedClaim).to have_received(:find).with(claim_id)
      expect(Assess::BaseViewModel).to have_received(:build).with(:letters_and_calls_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, letters_and_calls: })
      expect(response).to be_successful
    end
  end

  context 'edit' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Assess::LettersCallsForm) }
    let(:letters_and_calls) { [calls, letters] }
    let(:calls) { instance_double(Assess::V1::LetterAndCall, type: double(value: 'calls'), form_attributes: {}) }
    let(:letters) { instance_double(Assess::V1::LetterAndCall, type: double(value: 'letters'), form_attributes: {}) }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive(:build).and_return(letters_and_calls)
      allow(Assess::LettersCallsForm).to receive(:new).and_return(form)
    end

    context 'when type is unknown' do
      it 'raises an error' do
        expect do
          get :edit, params: { claim_id: claim_id, id: 'other' }
        end.to raise_error(/No route matches/)
      end
    end

    context 'when URL is for letters' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: claim_id, id: 'letters' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, form: form, item: letters })
        expect(response).to be_successful
      end
    end

    context 'when URL is for calls' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: claim_id, id: 'calls' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, form: form, item: calls })
        expect(response).to be_successful
      end
    end
  end

  context 'show' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:letters_and_calls) { [calls, letters] }
    let(:calls) { instance_double(Assess::V1::LetterAndCall, type: double(value: 'calls'), form_attributes: {}) }
    let(:letters) { instance_double(Assess::V1::LetterAndCall, type: double(value: 'letters'), form_attributes: {}) }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive(:build).and_return(letters_and_calls)
    end

    context 'when type is unknown' do
      it 'raises an error' do
        expect do
          get :show, params: { claim_id: claim_id, id: 'other' }
        end.to raise_error(/No route matches/)
      end
    end

    context 'when URL is for letters' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :show, params: { claim_id: claim_id, id: 'letters' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, item: letters })
        expect(response).to be_successful
      end
    end

    context 'when URL is for calls' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :show, params: { claim_id: claim_id, id: 'calls' }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, item: calls })
        expect(response).to be_successful
      end
    end
  end

  context 'update' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id, risk: 'high') }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Assess::LettersCallsForm, save:) }
    let(:letters_and_calls) { [calls, letters] }
    let(:calls) { instance_double(Assess::V1::LetterAndCall, type: double(value: 'calls'), form_attributes: {}) }
    let(:letters) { instance_double(Assess::V1::LetterAndCall, type: double(value: 'letters'), form_attributes: {}) }

    before do
      allow(Assess::BaseViewModel).to receive(:build).and_return(letters_and_calls)
      allow(Assess::LettersCallsForm).to receive(:new).and_return(form)
      allow(SubmittedClaim).to receive(:find).and_return(claim)
    end

    context 'for letters' do
      context 'when form save is successful' do
        let(:save) { true }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update, params: { claim_id: claim_id, id: 'letters', assess_letters_calls_form_letters: { some: :data } }

          expect(controller).to redirect_to(assess_claim_adjustments_path(claim, anchor: 'letters-and-calls-tab'))
          expect(response).to have_http_status(:found)
        end
      end

      context 'when form save is unsuccessful' do
        let(:save) { false }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update, params: { claim_id: claim_id, id: 'letters', assess_letters_calls_form_letters: { some: :data } }

          expect(controller).to have_received(:render)
                            .with(:edit, locals: { claim: claim, form: form, item: letters })
          expect(response).to be_successful
        end
      end
    end

    context 'for calls' do
      context 'when form save is successful' do
        let(:save) { true }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update, params: { claim_id: claim_id, id: 'calls', assess_letters_calls_form_calls: { some: :data } }

          expect(controller).to redirect_to(assess_claim_adjustments_path(claim, anchor: 'letters-and-calls-tab'))
          expect(response).to have_http_status(:found)
        end
      end

      context 'when form save is unsuccessful' do
        let(:save) { false }

        it 'renders successfully with claims' do
          allow(controller).to receive(:render)
          put :update, params: { claim_id: claim_id, id: 'calls', assess_letters_calls_form_calls: { some: :data } }

          expect(controller).to have_received(:render)
                            .with(:edit, locals: { claim: claim, form: form, item: calls })
          expect(response).to be_successful
        end
      end
    end
  end
end
