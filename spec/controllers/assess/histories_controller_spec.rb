require 'rails_helper'

RSpec.describe Assess::HistoriesController do
  let(:caseworker) { create(:caseworker) }
  let(:claim) { create(:submitted_claim, id: claim_id, events: events) }
  let(:claim_id) { SecureRandom.uuid }
  let(:events) { [build(:event, :note)] }
  let(:claim_summary) { instance_double(Assess::V1::ClaimSummary) }
  let(:claim_note) { instance_double(Assess::ClaimNoteForm, save: save, id: claim_id) }
  let(:save) { true }

  before do
    allow(SubmittedClaim).to receive(:find).and_return(claim)
    allow(Assess::BaseViewModel).to receive_messages(build: claim_summary)
    allow(Assess::ClaimNoteForm).to receive(:new).and_return(claim_note)
  end

  context 'show' do
    it 'find and builds the required object' do
      get :show, params: { claim_id: }

      expect(Assess::BaseViewModel).to have_received(:build).with(:claim_summary, claim)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :show, params: { claim_id: }

      expect(controller).to have_received(:render).with(
        locals: {
          claim: claim, claim_summary: claim_summary, history_events: claim.events.history,
          claim_note: claim_note, pagy: anything
        }
      )
      expect(response).to be_successful
    end
  end

  context 'create' do
    let(:user) { instance_double(User, role: 'caseworker') }
    let(:risk_level) { 'high' }

    it 'builds a note object' do
      post :create, params: {
        claim_id: claim.id,
        assess_claim_note_form: { note: 'new note', id: claim.id }
      }

      expect(Assess::ClaimNoteForm).to have_received(:new).with(
        'note' => 'new note', 'id' => claim.id, 'current_user' => caseworker
      )
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        post :create, params: {
          claim_id: claim.id,
          assess_claim_note_form: { note: 'new note', id: claim.id }
        }

        expect(controller).to have_received(:render).with(
          :show, locals: {
            claim: claim, claim_summary: claim_summary, history_events: claim.events.history,
            claim_note: claim_note, pagy: anything
          }
        )
      end
    end
  end
end
