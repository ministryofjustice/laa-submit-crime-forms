require 'rails_helper'

RSpec.describe Steps::WorkItemController, type: :controller do
  let(:work_item) { existing_case.is_a?(Claim) ? existing_case.work_items.create : nil }

  it_behaves_like 'a generic step controller', Steps::WorkItemForm, Decisions::DecisionTree,
                  ->(scope) { { work_item_id: scope.work_item&.id || '4321' } }
  it_behaves_like 'a step that can be drafted', Steps::WorkItemForm,
                  ->(scope) { { work_item_id: scope.work_item&.id || '4321' } }

  describe '#edit' do
    let(:application) { create(:claim, work_items:) }
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

      context 'when NEW_RECORD passed as id' do
        it 'does not save the new work_item it passes to the form' do
          allow(Steps::WorkItemForm).to receive(:build)
          expect { get :edit, params: { id: application, work_item_id: StartPage::NEW_RECORD } }
            .not_to change(application.work_items, :count)

          expect(Steps::WorkItemForm).to have_received(:build) do |wi, **kwargs|
            expect(wi).to be_a(WorkItem)
            expect(wi).to be_new_record
            expect(kwargs).to eq(application:)
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

  describe '#duplicate' do
    let(:application) { create(:claim) }
    let(:work_item) { nil }

    before do
      # initialize the data to ensure the tests work as expected
      application
      work_item
    end

    context 'when existing work_item_id is passed in' do
      let(:work_item) { create(:work_item, claim: application) }

      it 'creates a duplicate work item and redirects to the edit page' do
        expect do
          get :duplicate, params: { id: application, work_item_id: work_item.id }
        end.to change(application.work_items, :count).by(1)

        new_record_id = application.work_items.pluck(:id).detect { |id| id != work_item.id }
        expect(response).to redirect_to(edit_steps_work_item_path(application, work_item_id: new_record_id))
      end
    end

    context 'when existing work_item_id is NEW_RECORD' do
      let(:work_item) { build(:work_item, id: StartPage::NEW_RECORD) }

      it 'redirects to the NEW_RECORD page' do
        expect do
          get :duplicate, params: { id: application, work_item_id: work_item.id }
        end.not_to change(application.work_items, :count)

        expect(response).to redirect_to(edit_steps_work_item_path(application, work_item_id: StartPage::NEW_RECORD))
      end
    end

    context 'when unknown work_item_id is passed in' do
      it 'redirects to the summary page' do
        expect do
          get :duplicate, params: { id: application, work_item_id: SecureRandom.uuid }
        end.not_to change(application.work_items, :count)

        expect(response).to redirect_to(edit_steps_work_items_path(application))
      end
    end
  end
end
