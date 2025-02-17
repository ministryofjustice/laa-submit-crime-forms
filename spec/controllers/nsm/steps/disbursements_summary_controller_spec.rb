require 'rails_helper'

RSpec.describe Nsm::Steps::DisbursementsController, type: :controller do
  context 'when some disbursements are incomplete' do
    let(:claim) { create(:claim, disbursements:) }
    let(:disbursements) do
      [
        build(:disbursement, :valid),
        build(:disbursement, :valid, disbursement_date: nil),
        build(:disbursement, :valid, disbursement_date: nil)
      ]
    end

    before do
      allow(controller).to receive(:current_application).and_return(claim)
    end

    it 'generates the correct error summary' do
      get :edit, params: { id: claim.id }
      expect(controller.instance_variable_get(:@items_incomplete_flash)[:default])
        .to include('2 disbursements are incomplete:')
    end
  end

  it_behaves_like 'a generic step controller', Steps::AddAnotherForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::AddAnotherForm
end
