require 'rails_helper'

RSpec.describe Steps::WorkItemController, type: :controller do
  it_behaves_like 'a generic step controller', Steps::WorkItemForm, Decisions::SimpleDecisionTree
  it_behaves_like 'a step that can be drafted', Steps::WorkItemForm

  describe '#edit' do
    let(:application) { Claim.create(office_code: 'AA1', work_items: work_items) }
    let(:work_items) { [] }

    context 'when work_item_id is not passed in' do
      context 'when work item already exists' do
        let(:work_items) { [WorkItem.new] }

        it 'passes the existing work_item to the form' do
          allow(Steps::WorkItemForm).to receive(:build)
          expect { get :edit, params: { id: application } }.not_to change(application.work_items, :count)

          expect(Steps::WorkItemForm).to have_received(:build).with(work_items.first, application:)
        end
      end

      context 'when no main work_items exists' do
        it 'creates a new main work_item and passes it to the form' do
          allow(Steps::WorkItemForm).to receive(:build)
          expect { get :edit, params: { id: application } }.to change(application.work_items, :count).by(1)

          expect(Steps::WorkItemForm).to have_received(:build).with(application.reload.work_items.last,
                                                                    application:)
        end
      end
    end

    context 'when work_item_id is passed in' do
      context 'and work_item exists' do
        let(:work_items) { [WorkItem.new] }

        it 'passes the existing work_item to the form' do
          allow(Steps::WorkItemForm).to receive(:build)
          expect do
            get :edit,
                params: { id: application, work_item_id: application.work_items.first.id }
          end.not_to change(application.work_items, :count)

          expect(Steps::WorkItemForm).to have_received(:build).with(work_items.first, application:)
        end
      end

      context 'and work_item does not exists' do
        let(:work_items) { [] }

        it 'redirects to the summary page' do
          expect do
            get :edit, params: { id: application, work_item_id: SecureRandom.uuid }
          end.not_to change(application.work_items, :count)

          expect(response).to redirect_to(edit_steps_work_items_path(application))
        end
      end
    end
  end
end
