require 'rails_helper'

RSpec.describe ClaimsController do
  context 'index' do
    let(:scope) { double(:scope, not: [instance_double(Claim)]) }

    before do
      allow(Claim).to receive_message_chain(:where, :order).and_return(scope)
      allow(scope).to receive_message_chain(:page, :per).and_return(scope)
      get :index
    end

    it 'renders successfully with claims' do
      expect(response).to render_template(:index)
      expect(response).to be_successful
    end

    it 'retrieves valid claims' do
      expect(Claim).to have_received(:where).with(claim_type: %w[non_standard_magistrate breach_of_injunction])
    end
  end

  context 'create' do
    let(:claim) { instance_double(Claim, id: SecureRandom.uuid) }

    before do
      allow(Claim).to receive(:create!).and_return(claim)
    end

    it 'create a new Claim application with the users office_code' do
      post :create
      expect(Claim).to have_received(:create!).with(hash_including(office_code:  'AAA'))
    end

    it 'create a new Claim application with an laa reference' do
      post :create
      expect(Claim).to have_received(:create!).with(hash_including(:laa_reference))
    end

    it 'redirects to the edit claim type step' do
      post :create
      expect(response).to redirect_to(edit_steps_claim_type_path(claim.id))
    end
  end

  context 'generate LAA reference' do
    it 'generates reference starting with: LAA- and ending in 6 alphanumeric digits' do
      expect(subject.send(:generate_laa_reference)).to match(/LAA-[A-Za-z0-9]+/)
    end
end
