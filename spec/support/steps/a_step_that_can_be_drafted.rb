RSpec.shared_examples 'a step that can be drafted' do |form_class, additional_params_callback = nil|
  describe '#update' do
    let(:additional_params) { additional_params_callback&.call(self) || {} }
    let(:form_object) { instance_double(form_class, attributes: { foo: double }) }
    let(:form_class_params_name) { form_class.name.underscore }
    let(:expected_params) do
      { :id => existing_case, form_class_params_name => { foo: 'bar' }, :commit_draft => '', **additional_params }
    end

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

    context 'when an application in progress is found' do
      let(:existing_case) { create(:claim) }

      before do
        allow(form_class).to receive(:new).and_return(form_object)
      end

      context 'when the form saves successfully' do
        before do
          expect(form_object).to receive(:save!).and_return(true)
        end

        it 'redirects to the application task list' do
          put :update, params: expected_params
          expect(subject).to redirect_to(after_commit_path(existing_case))
        end
      end

      context 'when the form fails to save it does not matter' do
        before do
          expect(form_object).to receive(:save!).and_return(false)
        end

        it 'redirects to the application task list' do
          put :update, params: expected_params
          expect(subject).to redirect_to(after_commit_path(existing_case))
        end
      end
    end
  end
end
