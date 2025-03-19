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
      expect(controller.instance_variable_get(:@items_incomplete_flash))
        .to include('2 items have missing or incorrect information:')
    end

    it 'creates the correct link for incomplete disbursement' do
      incomplete_work_items = claim.work_items.reject(&:complete?).sort_by(&:position)
      get :edit, params: { id: claim.id }

      flash = controller.instance_variable_get(:@items_incomplete_flash)
      expect(flash).to include(incomplete_work_items[0].id)
      expect(flash).to include(incomplete_work_items[1].id)
    end
  end

  it_behaves_like 'a generic step controller', Steps::AddAnotherForm, Decisions::DecisionTree
  it_behaves_like 'a step that can be drafted', Steps::AddAnotherForm
end
