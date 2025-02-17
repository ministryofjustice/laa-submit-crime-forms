require 'rails_helper'

RSpec.describe Nsm::Steps::WorkItemsController, type: :controller do
  context 'when some work items are incomplete' do
    let(:claim) { create(:claim, work_items:) }
    let(:work_items) do
      [
        build(:work_item, :valid),
        build(:work_item, :valid, time_spent: nil),
        build(:work_item, :valid, time_spent: nil)
      ]
    end

    before do
      allow(controller).to receive(:current_application).and_return(claim)
    end

    it 'generates the correct error summary' do
      get :edit, params: { id: claim.id }
      expect(controller.instance_variable_get(:@items_incomplete_flash)[:default])
        .to include('2 work items are incomplete:')
    end
  end

  it_behaves_like 'a generic step controller', Steps::AddAnotherForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::AddAnotherForm
end
