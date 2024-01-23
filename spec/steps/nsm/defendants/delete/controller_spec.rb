require 'rails_helper'

RSpec.describe Nsm::Steps::DefendantDeleteController, type: :controller do
  before do
    # Needed because some specs that include these examples stub current_application,
    # which is undesirable for this particular test
    allow(controller).to receive(:current_application).and_return(current_application)
  end

  describe '#edit' do
    context 'when application is not found' do
      let(:current_application) { nil }

      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345', defendant_id: '3333' }
        expect(response).to redirect_to(controller.laa_msf.application_not_found_errors_path)
      end
    end

    # NOTE: for now it is ok to assume we just have the applicant, but when we
    # integrate the partner steps, this will have to either be passed as configuration
    # to the shared examples, or to also create the partner associated record.
    #
    context 'when application is found' do
      let(:existing_case) { create(:claim) }
      let(:current_application) do
        instance_double(Claim, defendants: defendants, navigation_stack: [], 'navigation_stack=': true, save!: true)
      end
      let(:defendants) { double(:defendants, find_by: defendant) }
      let(:form) { instance_double(Nsm::Steps::DefendantDeleteForm) }

      before do
        allow(Nsm::Steps::DefendantDeleteForm).to receive(:build).and_return(form)
      end

      context 'when defendant id is passes in' do
        let(:defendants) { double(:defendants, find_by: defendant) }

        context 'and defendant exists' do
          let(:defendant) { instance_double(Defendant) }

          it 'responds with HTTP success' do
            get :edit, params: { id: existing_case, defendant_id: SecureRandom }
            expect(response).to be_successful
          end
        end

        context 'and defendant does not exists' do
          let(:defendant) { nil }

          it 'redirects to the summary page' do
            get :edit, params: { id: existing_case, defendant_id: SecureRandom }

            expect(response).to redirect_to(edit_steps_defendant_summary_path(current_application))
          end
        end
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(Nsm::Steps::DefendantDeleteForm, attributes: { foo: double }) }
    let(:form_object_params_name) { Nsm::Steps::DefendantDeleteForm.name.underscore }
    let(:expected_params) do
      { :id => existing_case, :defendant_id => defendant_id, form_object_params_name => { foo: 'bar' } }
    end
    let(:current_application) { instance_double(Claim, defendants:) }
    let(:defendants) { double(:defendants, find_by: defendant) }
    let(:defendant_id) { SecureRandom.uuid }
    let(:defendant) { nil }

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
      let(:existing_case) { create(:claim) }
      let(:current_application) do
        instance_double(Claim, defendants: defendants, navigation_stack: [], 'navigation_stack=': true, save!: true)
      end
      let(:form) { instance_double(Nsm::Steps::DefendantDeleteForm) }

      before do
        allow(Nsm::Steps::DefendantDeleteForm).to receive(:build).and_return(form)
      end

      context 'when defendant id is passes in' do
        let(:defendants) { double(:defendants, find_by: defendant) }
        let(:defendant) { instance_double(Defendant) }

        context 'and defendant exists' do
          let(:existing_case) { create(:claim) }

          before do
            allow(Nsm::Steps::DefendantDeleteForm).to receive(:new).and_return(form_object)
          end

          context 'when the form saves successfully' do
            before do
              expect(form_object).to receive(:save).and_return(true)
            end

            let(:decision_tree) { instance_double(Decisions::DecisionTree, destination: '/expected_destination') }

            it 'asks the decision tree for the next destination and redirects there' do
              expect(Decisions::DecisionTree).to receive(:new).and_return(decision_tree)
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

        context 'and defendant does not exists' do
          let(:defendant) { nil }

          it 'redirects to the summary page' do
            get :edit, params: { id: existing_case, defendant_id: SecureRandom }

            expect(response).to redirect_to(edit_steps_defendant_summary_path(current_application))
          end
        end
      end
    end
  end
end
