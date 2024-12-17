require 'rails_helper'

RSpec.describe Nsm::Steps::SolicitorDeclarationController, type: :controller do
  let(:claim) do
    create(:claim,
           :complete,
           :case_type_breach,
           state: :draft)
  end

  describe '#edit' do
    context 'when application is not found' do
      it 'redirects to the application not found error page' do
        get :edit, params: { id: '12345' }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when application is found' do
      it 'responds with HTTP success' do
        get :edit, params: { id: claim.id }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(Nsm::Steps::SolicitorDeclarationForm, attributes: { foo: double }) }
    let(:expected_params) { { id: claim_id, nsm_steps_solicitor_declaration_form: { foo: 'bar' } } }

    context 'when application is not found' do
      let(:claim_id) { '12345' }

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when an application in progress is found' do
      let(:claim_id) { claim.id }

      before do
        allow(Nsm::Steps::SolicitorDeclarationForm).to receive(:new).and_return(form_object)
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
  end
end
