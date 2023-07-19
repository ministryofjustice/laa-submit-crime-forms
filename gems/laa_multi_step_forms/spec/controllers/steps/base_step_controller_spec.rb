require 'rails_helper'

RSpec.describe DummyStepController, type: :controller do
  describe 'navigation stack' do
    let(:application_id) { SecureRandom.uuid }
    let!(:application) do
      double(:claim, id: application_id, save!: true, 'navigation_stack=': true, navigation_stack: navigation_stack)
    end
    let(:dummy_step_path) { "/dummy_step/#{application_id}" }

    before do
      allow(DummyStepImplementation).to receive(:current_application).and_return(application)

      get :show, params: { id: application_id }
    end

    context 'when the stack is empty' do
      let(:navigation_stack) { [] }

      it 'adds the page to the stack' do
        expect(application).to have_received(:navigation_stack=).with([dummy_step_path])
      end
    end

    context 'when the current page is on the stack' do
      let(:navigation_stack) { ['/foo', '/bar', dummy_step_path, '/baz'] }

      it 'rewinds the stack to the appropriate point' do
        expect(application).to have_received(:navigation_stack=).with(['/foo', '/bar', dummy_step_path])
      end
    end

    context 'when the current page is not on the stack' do
      let(:navigation_stack) { %w[/foo /bar /baz] }

      it 'adds it to the end of the stack' do
        expect(application).to have_received(:navigation_stack=).with(navigation_stack + [dummy_step_path])
      end
    end
  end

  describe '#update_and_advance' do
    let(:application) { double(:application, id: SecureRandom.uuid) }
    let(:form_class) do
      class_double(Steps::BaseFormObject,
                   model_name: double(:model_name, singular: 'test_model'),
                   attribute_names: %w[first second],
                   new: form,)
    end
    let(:form) { instance_double(Steps::BaseFormObject, save!: true, save: save_form) }
    let(:save_form) { true }
    let(:options) { { as: :claim_type } }
    let(:decision_tree_class) { double(:decision_tree_class, new: decision_tree) }
    let(:decision_tree) { double(:decision_tree, destination:) }
    let(:destination) { { action: :show, id: application.id, controller: :dummy_step } }

    before do
      allow(DummyStepImplementation).to receive(:current_application).and_return(application)
      allow(DummyStepImplementation).to receive(:form_class).and_return(form_class)
      allow(DummyStepImplementation).to receive(:options).and_return(options)
      allow(DummyStepImplementation).to receive(:decision_tree_class).and_return(decision_tree_class)
    end

    context 'when saving as a draft' do
      let(:params) { { id: application.id, test_model: { first: 1, second: 2 }, commit_draft: true } }

      it 'sets the paramters on the form' do
        expect(form_class).to receive(:new).with({
                                                   'application' => application,
          'record' => nil,
          'first' => '1',
          'second' => '2',
                                                 })

        put :update, params:
      end

      context 'additional/missing params are passed in' do
        let(:params) { { id: application.id, test_model: { first: 1, third: 3 }, commit_draft: true } }

        it 'ignore additional and skips missing params' do
          expect(form_class).to receive(:new).with({
                                                     'application' => application,
            'record' => nil,
            'first' => '1',
                                                   })

          put :update, params:
        end
      end

      it 'calls save! on the form' do
        expect(form).to receive(:save!)

        put :update, params:
      end

      it 'redirects to the after_commit_path' do
        put(:update, params:)

        expect(response).to redirect_to(after_commit_path(application))
      end
    end

    context 'when refreshing (with save)' do
      let(:form) { instance_double(Steps::BaseFormObject, application: application, record: record, save!: true) }
      let(:record) { application }
      let(:params) { { id: application.id, test_model: { first: 1, second: 2 }, save_and_refresh: true } }

      it 'sets the paramters on the form' do
        expect(form_class).to receive(:new).with({
                                                   'application' => application,
          'record' => nil,
          'first' => '1',
          'second' => '2',
                                                 })

        put :update, params:
      end

      context 'additional/missing params are passed in' do
        let(:params) { { id: application.id, test_model: { first: 1, third: 3 }, commit_draft: true } }

        it 'ignore additional and skips missing params' do
          expect(form_class).to receive(:new).with({
                                                     'application' => application,
            'record' => nil,
            'first' => '1',
                                                   })

          put :update, params:
        end
      end

      it 'calls save! on the form' do
        expect(form).to receive(:save!)

        put :update, params:
      end

      it 'redirects to the form' do
        put(:update, params:)

        expect(response).to redirect_to(id: application.id)
      end

      context 'when then application and record do not match' do
        let(:record) { double(:record, id: SecureRandom.uuid, class: 'WorkItem') }

        it 'redirects to the form and record' do
          put(:update, params:)

          expect(response).to redirect_to(id: application.id, work_item_id: record.id)
        end
      end
    end

    context 'when saving the record' do
      let(:params) { { id: application.id, test_model: { first: 1, second: 2 } } }

      it 'sets the paramters on the form' do
        expect(form_class).to receive(:new).with({
                                                   'application' => application,
          'record' => nil,
          'first' => '1',
          'second' => '2',
                                                 })

        put :update, params:
      end

      context 'when saving is successful' do
        it 'gets the path from the decision_tree_class' do
          expect(decision_tree_class).to receive(:new).with(
            form, options
          )

          put :update, params:
        end

        it 'redirects to the path from the decision_tree_class' do
          put(:update, params:)

          expect(response).to redirect_to(destination)
        end

        context 'when decision_tree_class is not defined' do
          before do
            allow(ENV).to(receive(:fetch)).and_call_original
            allow(ENV).to(receive(:fetch)).with('RAILS_ENV', nil).and_return('development')
          end

          let(:decision_tree_class) { nil }

          it 'raises an error' do
            expect { put :update, params: }.to raise_error('implement this action, in subclasses')
          end
        end
      end

      context 'when saving fails' do
        let(:save_form) { false }

        it 'renders the edit page' do
          put(:update, params:)

          expect(response).to render_template(:edit)
        end
      end
    end
  end
end
