require 'rails_helper'

RSpec.describe Nsm::Steps::StartPageController, type: :controller do
  it_behaves_like 'a show step controller'

  describe '#show' do
    let(:claim) { create(:claim) }

    before { claim.update(navigation_stack:, status:) }

    context 'when page is already in navigation stack' do
      let(:navigation_stack) { ["/non-standard-magistrates/applications/#{claim.id}/steps/start_page", '/foo'] }
      let(:status) { 'draft' }

      it 'does not change the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          navigation_stack:
        )
      end
    end

    context 'when page is not in the navigation stack' do
      let(:navigation_stack) { ['/foo'] }
      let(:status) { 'draft' }

      it 'adds the page to the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          navigation_stack: ['/foo', "/non-standard-magistrates/applications/#{claim.id}/steps/start_page"]
        )
      end
    end

    context 'when claim is in a submitted state' do
      let(:navigation_stack) { ['/foo'] }
      let(:status) { 'submitted' }

      it 'redirects to the read only view' do
        get :show, params: { id: claim }

        expect(response).to redirect_to("/non-standard-magistrates/applications/#{claim.id}/steps/view_claim")
      end
    end
  end
end
