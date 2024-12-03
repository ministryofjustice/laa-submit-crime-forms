require 'rails_helper'

RSpec.describe Nsm::Steps::CheckAnswersController, type: :controller do
  it_behaves_like 'a show step controller'

  describe '#show' do
    let(:claim) { create(:claim, :complete) }

    before { claim.update(viewed_steps:) }

    context 'when page is already in navigation stack and at the end' do
      let(:viewed_steps) { %w[claim_type check_answers] }

      it 'does not change the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps:
        )
      end
    end

    context 'when page is already in navigation stack but not at the end' do
      let(:viewed_steps) { %w[check_answers equality] }

      it 'does not change the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps:
        )
      end
    end

    context 'when page is not in the navigation stack' do
      let(:viewed_steps) { ['claim_type'] }

      it 'adds the page to the navigation stack' do
        get :show, params: { id: claim }
        expect(claim.reload).to have_attributes(
          viewed_steps: %w[claim_type check_answers]
        )
      end
    end
  end
end
