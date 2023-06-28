require 'rails_helper'

RSpec.describe Steps::WorkItemDeleteController, type: :controller do
  before do
    # Needed because some specs that include these examples stub current_application,
    # which is undesirable for this particular test
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#edit' do
    context 'when application is not found' do
      let(:current_application) { nil }

      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', work_item_id: SecureRandom.uuid }
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    # NOTE: for now it is ok to assume we just have the applicant, but when we
    # integrate the partner steps, this will have to either be passed as configuration
    # to the shared examples, or to also create the partner associated record.
    #
    context 'when application is found' do
      let(:existing_case) { Claim.create(office_code: 'AAA') }
      let(:current_application) do
        instance_double(Claim, work_items: work_items, navigation_stack: [], 'navigation_stack=': true, save!: true)
      end
      let(:work_items) { double(:work_items, find_by: work_item) }
      let(:form) { instance_double(Steps::DeleteForm) }

      before do
        allow(Steps::DeleteForm).to receive(:build).and_return(form)
      end

      context 'when work_item id is passes in' do
        context 'and work_item exists' do
          let(:work_item) { instance_double(WorkItem) }

          it 'responds with HTTP success' do
            get :edit, params: { id: existing_case, work_item_id: SecureRandom }
            expect(response).to be_successful
          end
        end

        context 'and work_item does not exists' do
          let(:work_item) { nil }

          it 'redirects to the summary page' do
            get :edit, params: { id: existing_case, work_item_id: SecureRandom }

            expect(response).to redirect_to(edit_steps_work_items_path(current_application))
          end
        end
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(Steps::DeleteForm, attributes: { foo: double }) }
    let(:form_object_params_name) { Steps::DeleteForm.name.underscore }
    let(:expected_params) do
      { :id => existing_case, form_object_params_name => { foo: 'bar' }, :work_item_id => SecureRandom.uuid }
    end
    let(:current_application) { instance_double(Claim, work_items:) }
    let(:work_items) { double(:work_items, find_by: work_item) }
    let(:work_item) { nil }

    context 'when application is not found' do
      let(:existing_case) { '12345' }

      before do
        # Needed because some specs that include these examples stub current_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      let(:existing_case) { Claim.create(office_code: 'AAA') }
      let(:current_application) do
        instance_double(Claim, work_items: work_items, navigation_stack: [], 'navigation_stack=': true, save!: true)
      end
      let(:form) { instance_double(Steps::DeleteForm) }

      before do
        allow(Steps::DeleteForm).to receive(:build).and_return(form)
      end

      context 'when work_item id is passes in' do
        let(:work_item) { instance_double(WorkItem) }

        context 'and work_item exists' do
          let(:existing_case) { Claim.create!(office_code: 'AAA') }

          before do
            allow(Steps::DeleteForm).to receive(:new).and_return(form_object)
          end

          context 'when the form saves successfully' do
            before do
              expect(form_object).to receive(:save).and_return(true)
            end

            let(:decision_tree) { instance_double(Decisions::SimpleDecisionTree, destination: '/expected_destination') }

            it 'asks the decision tree for the next destination and redirects there' do
              expect(Decisions::SimpleDecisionTree).to receive(:new).and_return(decision_tree)
              put :update, params: expected_params
              expect(response).to have_http_status(:redirect)
              expect(subject).to redirect_to('/expected_destination')
            end
          end

          context 'when the form fails to save' do
            before do
              expect(form_object).to receive(:save).and_return(false)
            end

            it 'renders the question page again' do
              put :update, params: expected_params
              expect(response).to have_http_status(:ok)
            end
          end
        end

        context 'and work_item does not exists' do
          let(:work_item) { nil }

          it 'redirects to the summary page' do
            get :edit, params: { id: existing_case, work_item_id: SecureRandom.uuid }

            expect(response).to redirect_to(edit_steps_work_items_path(current_application))
          end
        end
      end
    end
  end
end
