require 'rails_helper'

RSpec.describe Nsm::Steps::WorkItemController, type: :controller do
  let(:work_item) { existing_case.is_a?(Claim) ? existing_case.work_items.create : nil }

  it_behaves_like 'a generic step controller', Nsm::Steps::WorkItemForm, Decisions::DecisionTree,
                  ->(scope) { { work_item_id: scope.work_item&.id || '4321' } }
  it_behaves_like 'a step that can be drafted', Nsm::Steps::WorkItemForm,
                  ->(scope) { { work_item_id: scope.work_item&.id || '4321' } }

  describe '#edit' do
    let(:application) { create(:claim, :firm_details, work_items:) }
    let(:work_items) { [] }

    context 'when work_item_id is not passed in' do
      context 'when work item already exists' do
        let(:work_items) { [WorkItem.new] }

        it 'passes the existing work_item to the form' do
          allow(Nsm::Steps::WorkItemForm).to receive(:build)
          expect do
            get :edit,
                params: { id: application, work_item_id: work_items.first.id }
          end.not_to change(application.work_items, :count)

          expect(Nsm::Steps::WorkItemForm).to have_received(:build).with(work_items.first, application:)
        end
      end

      context 'when NEW_RECORD passed as id' do
        it 'does not save the new work_item it passes to the form' do
          allow(Nsm::Steps::WorkItemForm).to receive(:build)
          expect { get :edit, params: { id: application, work_item_id: Nsm::StartPage::NEW_RECORD } }
            .not_to change(application.work_items, :count)

          expect(Nsm::Steps::WorkItemForm).to have_received(:build) do |wi, **kwargs|
            expect(wi).to be_a(WorkItem)
            expect(wi).to be_new_record
            expect(kwargs).to eq(application:)
          end
        end

        context 'when duplicating an existing work item' do
          let(:existing_work_item) { create(:work_item, claim: application, time_spent: 504) }

          it 'prepopulates copying from existing item' do
            allow(Nsm::Steps::WorkItemForm).to receive(:build)
            get :edit,
                params: { id: application,
                          work_item_id: Nsm::StartPage::NEW_RECORD,
                          work_item_to_duplicate: existing_work_item.id }

            expect(Nsm::Steps::WorkItemForm).to have_received(:build) do |wi, **_kwargs|
              expect(wi.time_spent).to eq 504
              expect(wi).to be_new_record
            end
          end
        end
      end
    end

    context 'when work_item_id is passed in' do
      context 'and work_item exists' do
        let(:work_items) { [WorkItem.new] }

        it 'passes the existing work_item to the form' do
          allow(Nsm::Steps::WorkItemForm).to receive(:build)
          expect do
            get :edit,
                params: { id: application, work_item_id: application.work_items.first.id }
          end.not_to change(application.work_items, :count)

          expect(Nsm::Steps::WorkItemForm).to have_received(:build).with(work_items.first, application:)
        end
      end

      context 'and work_item does not exists' do
        let(:work_items) { [] }

        it 'redirects to the summary page' do
          expect do
            get :edit, params: { id: application, work_item_id: SecureRandom.uuid }
          end.not_to change(application.work_items, :count)

          expect(response).to redirect_to(edit_nsm_steps_work_items_path(application))
        end
      end
    end
  end
end
