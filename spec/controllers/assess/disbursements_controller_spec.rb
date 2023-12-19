require 'rails_helper'

RSpec.describe Assess::DisbursementsController do
  let(:caseworker) { create(:caseworker) }

  context 'index' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:disbursements) { [instance_double(Assess::V1::Disbursement, disbursement_date: Time.zone.today)] }
    let(:grouped_disbursements) { { Time.zone.today => disbursements } }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive_messages(build: disbursements)
    end

    it 'find and builds the required object' do
      get :index, params: { claim_id: }

      expect(SubmittedClaim).to have_received(:find).with(claim_id)
      expect(Assess::BaseViewModel).to have_received(:build).with(:disbursement, claim, 'disbursements')
    end

    it 'renders successfully with claims' do
      allow(controller).to receive(:render)
      get :index, params: { claim_id: }

      expect(controller).to have_received(:render).with(locals: { claim: claim, disbursements: grouped_disbursements })
      expect(response).to be_successful
    end
  end

  context 'show' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:disbursement_id) { SecureRandom.uuid }
    let(:disbursement) do
      instance_double(Assess::V1::Disbursement, id: disbursement_id, attributes: attributes, form_attributes: {})
    end
    let(:attributes) do
      {
        'id' => disbursement_id,
        'miles' => nil,
        'details' => 'Details',
        'pricing' => 1.0,
        'vat_rate' => 0.2,
        'apply_vat' => 'false',
        'other_type' => {
          'en' => 'Apples',
          'value' => 'Apples'
        },
        'vat_amount' => 0.0,
        'prior_authority' => 'yes',
        'disbursement_date' => '2022-12-12',
        'disbursement_type' => {
          'en' => 'Other',
          'value' => 'other'
        },
        'total_cost_without_vat' => 100.0
      }
    end

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive(:build).and_return([disbursement])
    end

    context 'when URL is for disburement' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :show, params: { claim_id: claim_id, id: disbursement_id }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, item: disbursement })
        expect(response).to be_successful
      end
    end
  end

  context 'edit' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Assess::DisbursementsForm) }
    let(:disbursement_id) { SecureRandom.uuid }
    let(:disbursement) do
      instance_double(Assess::V1::Disbursement, id: disbursement_id, attributes: attributes, form_attributes: {})
    end
    let(:attributes) do
      {
        'id' => disbursement_id,
        'miles' => nil,
        'details' => 'Details',
        'pricing' => 1.0,
        'vat_rate' => 0.2,
        'apply_vat' => 'false',
        'other_type' => {
          'en' => 'Apples',
          'value' => 'Apples'
        },
        'vat_amount' => 0.0,
        'prior_authority' => 'yes',
        'disbursement_date' => '2022-12-12',
        'disbursement_type' => {
          'en' => 'Other',
          'value' => 'other'
        },
        'total_cost_without_vat' => 100.0
      }
    end

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive(:build).and_return([disbursement])
      allow(Assess::DisbursementsForm).to receive(:new).and_return(form)
    end

    context 'when URL is for disburement' do
      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        get :edit, params: { claim_id: claim_id, id: disbursement_id }

        expect(controller).to have_received(:render)
                          .with(locals: { claim: claim, form: form, item: disbursement })
        expect(response).to be_successful
      end
    end
  end

  context 'update' do
    let(:claim) { instance_double(SubmittedClaim, id: claim_id) }
    let(:claim_id) { SecureRandom.uuid }
    let(:form) { instance_double(Assess::DisbursementsForm, save:) }
    let(:disbursement_id) { '1c0f36fd-fd39-498a-823b-0a3837454563' }
    let(:disbursement) { instance_double(Assess::V1::Disbursement, id: disbursement_id, attributes: item) }
    let(:item) do
      instance_double(
        Assess::V1::Disbursement,
        id: '1c0f36fd-fd39-498a-823b-0a3837454563', # Getting from the factory
        provider_requested_total_cost_without_vat: provider_requested_total_cost_without_vat,
        total_cost_without_vat: current_total_cost_without_vat,
        vat_amount: 20.0,
      )
    end
    let(:current_total_cost_without_vat) { 100.0 }
    let(:total_cost_without_vat) { 'yes' }
    let(:provider_requested_total_cost_without_vat) { 100.0 }

    before do
      allow(SubmittedClaim).to receive(:find).and_return(claim)
      allow(Assess::BaseViewModel).to receive(:build).and_return([disbursement])
      allow(Assess::DisbursementsForm).to receive(:new).and_return(form)
    end

    context 'when form save is successful' do
      let(:save) { true }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        put :update, params: { claim_id: claim_id, id: disbursement_id, assess_disbursements_form: { some: :data } }

        expect(controller).to redirect_to(assess_claim_adjustments_path(claim, anchor: 'disbursements-tab'))
        expect(response).to have_http_status(:found)
      end
    end

    context 'when form save is unsuccessful' do
      let(:save) { false }

      it 'renders successfully with claims' do
        allow(controller).to receive(:render)
        put :update, params: { claim_id: claim_id, id: disbursement_id, assess_disbursements_form: { some: :data } }

        expect(controller).to have_received(:render)
                          .with(:edit, locals: { claim: claim, item: disbursement, form: form })
      end
    end
  end
end
