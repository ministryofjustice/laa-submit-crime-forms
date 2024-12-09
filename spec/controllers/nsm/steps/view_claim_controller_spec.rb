require 'rails_helper'

RSpec.describe Nsm::Steps::ViewClaimController, type: :controller do
  before { allow(AppStoreDetailService).to receive(:nsm).and_return(claim) }

  describe '#show' do
    let(:claim) { create(:claim, :complete, :completed_state) }
    let(:viewed_steps) { [] }

    before { claim.update(viewed_steps:) }

    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :show, params: { id: '12345' }
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      it 'responds with HTTP success' do
        get :show, params: { id: claim.id }
        expect(response).to be_successful
      end
    end

    context 'when page is already in navigation stack and at the end' do
      let(:viewed_steps) { %w[start_page view_claim] }

      it 'does not change the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps:
        )
      end
    end

    context 'when page is already in navigation stack but not at the end' do
      let(:viewed_steps) { ['view_claim'] }

      it 'removes entries after the page' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps: ['view_claim']
        )
      end
    end

    context 'when page is not in the navigation stack' do
      let(:viewed_steps) { ['start_page'] }

      it 'adds the page to the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps: %w[start_page view_claim]
        )
      end
    end
  end
end
