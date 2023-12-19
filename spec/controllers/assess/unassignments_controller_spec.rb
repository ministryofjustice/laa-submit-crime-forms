require 'rails_helper'

RSpec.describe Assess::UnassignmentsController do
  let(:caseworker) { create(:caseworker) }

  context 'edit' do
    let(:claim) { build(:submitted_claim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:unassignment) { instance_double(Assess::UnassignmentForm) }
    let(:defendant_name) { 'Tracy Linklater' }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::UnassignmentForm).to receive(:new).and_return(unassignment)
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :edit, params: { claim_id: }

      expect(controller).to have_received(:render)
                        .with(locals: { claim:, unassignment: })
      expect(response).to be_successful
    end
  end

  context 'update' do
    let(:unassignment) do
      instance_double(Assess::UnassignmentForm, save: save, unassignment_user: unassignment_user, user: caseworker)
    end
    let(:unassignment_user) { 'other' }
    let(:caseworker) { instance_double(User, display_name: 'Jim Bob', role: 'caseworker') }
    let(:claim) { create(:submitted_claim, :with_assignment) }
    let(:laa_reference_class) { instance_double(Assess::V1::LaaReference, laa_reference: 'AAA111') }
    let(:defendant_name) { 'Tracy Linklater' }
    let(:save) { true }

    before do
      allow(User).to receive(:first_or_create).and_return(caseworker)
      allow(Assess::UnassignmentForm).to receive(:new).and_return(unassignment)
      allow(Assess::BaseViewModel).to receive(:build).and_return(laa_reference_class)
      allow(SubmittedClaim).to receive(:find).and_return(claim)
    end

    it 'builds a decision object' do
      put :update, params: {
        claim_id: claim.id,
        assess_unassignment_form: { comment: 'some commment' }
      }
      expect(Assess::UnassignmentForm).to have_received(:new).with(
        'comment' => 'some commment', :claim => claim, 'current_user' => caseworker
      )
    end

    context 'when decision is updated' do
      it 'redirects to claim page' do
        put :update, params: {
          claim_id: claim.id,
          assess_unassignment_form: { comment: nil, id: claim.id }
        }

        expect(response).to redirect_to(assess_your_claims_path)
        expect(flash[:success]).to eq(
          "Claim <a class=\"govuk-link\" href=\"/assess/claims/#{claim.id}/claim_details\">AAA111</a> " \
          "has been removed from Jim Bob's list"
        )
      end

      context 'when current_user is the assigned user' do
        let(:unassignment_user) { 'assigned' }

        it 'redirects to claim page' do
          put :update, params: {
            claim_id: claim.id,
            assess_unassignment_form: { state: 'further_info', comment: nil, id: claim.id }
          }

          expect(response).to redirect_to(assess_your_claims_path)
          expect(flash[:success]).to eq(
            "<a class=\"govuk-link\" href=\"/assess/claims/#{claim.id}/claim_details\">AAA111</a> " \
            'has been removed from your list'
          )
        end
      end
    end

    context 'when decision has an erorr being updated' do
      let(:save) { false }

      it 're-renders the edit page' do
        allow(controller).to receive(:render)
        put :update, params: {
          claim_id: claim.id,
          assess_unassignment_form: { comment: nil, id: claim.id }
        }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim:, unassignment: })
      end
    end
  end
end
