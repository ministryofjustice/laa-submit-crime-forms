require 'rails_helper'

RSpec.describe Nsm::Steps::ViewClaimController, type: :controller do
  describe '#show' do
    let(:claim) { create(:claim, :complete, :completed_state) }
    let(:viewed_steps) { [] }

    before { claim.update(viewed_steps:) }

    context 'when application is not found' do
      before { allow(AppStoreDetailService).to receive(:nsm).and_return(nil) }

      it 'redirects to the application not found error page' do
        get :show, params: { id: '12345' }
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      before { allow(AppStoreDetailService).to receive(:nsm).and_return(claim) }

      it 'responds with HTTP success' do
        get :show, params: { id: claim.id }
        expect(response).to be_successful
      end
    end
  end
end
