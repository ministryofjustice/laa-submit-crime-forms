require 'rails_helper'

RSpec.describe Assess::ClaimsController do
  let(:caseworker) { create(:caseworker) }

  describe '#index' do
    it 'does not raise any errors' do
      expect { get :index }.not_to raise_error
    end
  end

  describe '#new' do
    context 'when a claim is available to assign' do
      it 'creates an assignment and event' do
        create(:submitted_claim)

        expect do
          expect { get :new }.to change(Assignment, :count).by(1)
        end.to change(Event::Assignment, :count).by(1)
      end

      it 'redirects to the assigned claim' do
        claim = create(:submitted_claim)

        get :new

        expect(response).to redirect_to(assess_claim_claim_details_path(claim))
      end
    end

    context 'when a claim is not available to assign' do
      it 'redirects to Your Claims with a flash notice' do
        get :new

        expect(response).to redirect_to(assess_your_claims_path)
        expect(flash[:notice]).to eq('There are no claims waiting to be allocated.')
      end
    end
  end
end
