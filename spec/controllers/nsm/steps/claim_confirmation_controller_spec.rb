require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimConfirmationController, type: :controller do
  describe '#show' do
    let(:claim) { create(:claim, state: 'submitted') }

    context 'when application is not found' do
      before { allow(AppStoreDetailService).to receive(:nsm).and_return(nil) }

      it 'redirects to the application not found error page' do
        get :show, params: { id: '12345' }
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      before { allow(AppStoreDetailService).to receive(:nsm).with(claim.id, claim.submitter).and_return(claim) }

      it 'responds with HTTP success' do
        get :show, params: { id: claim.id }
        expect(response).to be_successful
      end

      it 'renders the show template' do
        get :show, params: { id: claim }
        expect(response).to render_template(:show)
      end
    end
  end
end
