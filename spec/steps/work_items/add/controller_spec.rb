require 'rails_helper'

RSpec.describe Steps::WorkItemController, type: :controller do
  let(:work_item) { existing_case.is_a?(Claim) ? existing_case.work_items.create : nil }

  it_behaves_like 'a generic step controller', Steps::WorkItemForm, Decisions::SimpleDecisionTree,
                  ->(scope) { { work_item_id: scope.work_item&.id || '4321' } }
  it_behaves_like 'a step that can be drafted', Steps::WorkItemForm,
                  ->(scope) { { work_item_id: scope.work_item&.id || '4321' } }

  describe '#edit' do
    let(:application) { Claim.create(office_code: 'AA1', work_items: work_items) }
    let(:work_items) { [] }

    context 'when work_item_id is not passed in' do
      context 'when work item already exists' do
        let(:work_items) { [WorkItem.new] }

        it 'passes the existing work_item to the form' do
          allow(Steps::WorkItemForm).to receive(:build)
          expect do
            get :edit,
                params: { id: application, work_item_id: work_items.first.id }
          end.not_to change(application.work_items, :count)

          expect(Steps::WorkItemForm).to have_received(:build).with(work_items.first, application:)
        end
      end

      context 'when no main work_items exists and CREATE_FIRST passed as id' do
        it 'does not save the new work_item it passes to the form' do
          allow(Steps::WorkItemForm).to receive(:build)
          expect { get :edit, params: { id: application, work_item_id: StartPage::CREATE_FIRST } }
            .not_to change(application.work_items, :count)

          expect(Steps::WorkItemForm).to have_received(:build) do |wi, **kwargs|
            expect(wi).to be_a(WorkItem)
            expect(wi).to be_new_record
            expect(kwargs).to eq(application:)
          end
        end

        context 'and more than one work item exists' do
          let(:work_items) { [WorkItem.new, WorkItem.new] }

          it 'redirects to the summary page' do
            expect do
              get :edit, params: { id: application, work_item_id: StartPage::CREATE_FIRST }
            end.not_to change(application.work_items, :count)

            expect(response).to redirect_to(edit_steps_work_items_path(application))
          end
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
