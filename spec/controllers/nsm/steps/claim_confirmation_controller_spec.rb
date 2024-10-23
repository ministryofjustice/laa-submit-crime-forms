require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimConfirmationController, type: :controller do
  describe '#show' do
    let(:claim) { create(:claim, state: 'submitted') }
    let(:application) { instance_double(Claim, laa_reference: 'ABC123') }

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

    it 'assigns the correct application reference' do
      get :show, params: { id: claim }
      expect(application.laa_reference).to eq('ABC123')
    end

    it 'renders the show template' do
      get :show, params: { id: claim }
      expect(response).to render_template(:show)
    end
  end
end
