require 'rails_helper'

RSpec.describe Nsm::Steps::StartPageController, type: :controller do
  it_behaves_like 'a show step controller'

  describe '#show' do
    let(:claim) { create(:claim) }

    before { claim.update(viewed_steps:, state:) }

    context 'when page is already in navigation stack' do
      let(:viewed_steps) { %w[start_page claim_type] }
      let(:state) { 'draft' }

      it 'does not change the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps:
        )
      end
    end

    context 'when page is not in the navigation stack' do
      let(:viewed_steps) { ['claim_type'] }
      let(:state) { 'draft' }

      it 'adds the page to the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps: %w[claim_type start_page]
        )
      end
    end

    context 'when claim is in a submitted state' do
      let(:viewed_steps) { ['claim_type'] }
      let(:state) { 'submitted' }

      it 'redirects to the read only view' do
        get :show, params: { id: claim }

        expect(response).to redirect_to("/non-standard-magistrates/applications/#{claim.id}/steps/view_claim")
      end
    end
  end
end
