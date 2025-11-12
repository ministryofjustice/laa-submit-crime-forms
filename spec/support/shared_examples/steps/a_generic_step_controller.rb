RSpec.shared_examples 'a generic step controller' do |form_class, decision_tree_class, additional_params_callback = nil|
  let(:additional_params) { additional_params_callback&.call(self) || {} }

  describe '#edit' do
    context 'when application is not found' do
      let(:existing_case) { '12345' }

      before do
        # Needed because some specs that include these examples stub current_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        get :edit, params: { id: existing_case, **additional_params }
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    # NOTE: for now it is ok to assume we just have the applicant, but when we
    # integrate the partner steps, this will have to either be passed as configuration
    # to the shared examples, or to also create the partner associated record.
    #
    context 'when application is found' do
      let(:existing_case) { create(:claim, :firm_details, submitter: auth_provider) }

      it 'responds with HTTP success' do
        get :edit, params: { id: existing_case, **additional_params }
        expect(response).to be_successful
      end
    end
  end

  describe '#update' do
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) { { :id => existing_case, form_class_params_name => { foo: 'bar' }, **additional_params } }

    context 'when application is not found' do
      let(:existing_case) { '12345' }

      before do
        # Needed because some specs that include these examples stub current_application,
        # which is undesirable for this particular test
        allow(controller).to receive(:current_application).and_return(nil)
      end

      it 'redirects to the application not found error page' do
        put :update, params: expected_params
        expect(response).to redirect_to(application_not_found_errors_path)
      end
    end

    context 'when an application in progress is found' do
      let(:existing_case) { create(:claim, :firm_details, submitter: auth_provider) }

      before do
        allow(form_class).to receive(:new).and_return(form_object)
        allow(form_object).to receive(:valid?).and_return(true)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save).and_return(true)
        end

        let(:decision_tree) { instance_double(decision_tree_class, destination: '/expected_destination') }

        it 'asks the decision tree for the next destination and redirects there' do
          expect(decision_tree_class).to receive(:new).and_return(decision_tree)
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
