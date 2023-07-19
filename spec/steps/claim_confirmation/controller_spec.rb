require 'rails_helper'

RSpec.describe Steps::ClaimConfirmationController, type: :controller do
  it_behaves_like 'a show step controller'

  describe '#show' do
    let(:claim) { Claim.create!(office_code: 'AAA') }
    let(:application) { instance_double(Claim, laa_reference: 'ABC123') }

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
