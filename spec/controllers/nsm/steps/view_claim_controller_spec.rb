require 'rails_helper'

RSpec.describe Nsm::Steps::ViewClaimController, type: :controller do
  before { allow(AppStoreDetailService).to receive(:nsm).and_return(claim) }

  describe '#show' do
    let(:claim) { create(:claim, :complete, :completed_state) }
    let(:navigation_stack) { [] }

    before { claim.update(navigation_stack:) }

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
      let(:navigation_stack) { ['/foo', "/non-standard-magistrates/applications/#{claim.id}/steps/view_claim"] }

      it 'does not change the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          navigation_stack:
        )
      end
    end

    context 'when page is already in navigation stack but not at the end' do
      let(:navigation_stack) { ["/non-standard-magistrates/applications/#{claim.id}/steps/view_claim"] }

      it 'removes entries after the page' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          navigation_stack: ["/non-standard-magistrates/applications/#{claim.id}/steps/view_claim"]
        )
      end
    end

    context 'when page is not in the navigation stack' do
      let(:navigation_stack) { ['/foo'] }

      it 'adds the page to the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          navigation_stack: ['/foo', "/non-standard-magistrates/applications/#{claim.id}/steps/view_claim"]
        )
      end
    end
  end
end
