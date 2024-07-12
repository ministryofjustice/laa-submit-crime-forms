require 'rails_helper'

class FakeApp < Steps::BaseFormObject
  attribute :id
  attribute :navigation_stack

  def save!(*)
    true
  end

  def transaction(&block)
    true
  end
end

RSpec.describe DummyStepController, type: :controller do
  render_views

  let(:application_id) { SecureRandom.uuid }
  let(:navigation_stack) { [] }
  let!(:application) do
    FakeApp.new(id: application_id, navigation_stack: navigation_stack)
  end
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
    allow(application).to receive(:transaction)
    allow(DummyStepImplementation).to receive_messages(form_class: form_class, current_application: application,
                                                       options: options, decision_tree_class: decision_tree_class)
  end

  describe 'navigation stack' do
    let(:dummy_step_path) { "/dummy_step/#{application_id}" }

    context 'for show endpoints' do
      context 'when the stack is empty' do
        it 'adds the page to the stack' do
          get :show, params: { id: application_id }

          expect(application.navigation_stack).to eq([dummy_step_path])
        end

        context 'but skip_stack is true' do
          before do
            expect(DummyStepImplementation).to receive(:skip_stack).and_return(true)
          end

          it 'does not modify the stack' do
            get :show, params: { id: application_id }

            expect(application.navigation_stack).to eq([])
          end
        end
      end

      context 'when the current page is on the stack' do
        let(:navigation_stack) { ['/foo', '/bar', dummy_step_path, '/baz'] }

        it 'does not change the stack' do
          get :show, params: { id: application_id }

          expect(application.navigation_stack).to eq(['/foo', '/bar', dummy_step_path, '/baz'])
        end

        context 'but skip_stack is true' do
          before do
            expect(DummyStepImplementation).to receive(:skip_stack).and_return(true)
          end

          it 'does not modify the stack' do
            get :show, params: { id: application_id }

            expect(application.navigation_stack).to eq(['/foo', '/bar', dummy_step_path, '/baz'])
          end
        end
      end

      context 'when the current page is not on the stack' do
        let(:navigation_stack) { %w[/foo /bar /baz] }

        it 'adds it to the end of the stack' do
          get :show, params: { id: application_id }

          expect(application.navigation_stack).to eq(navigation_stack + [dummy_step_path])
        end

        context 'but skip_stack is true' do
          before do
            expect(DummyStepImplementation).to receive(:skip_stack).and_return(true)
          end

          it 'does not modify the stack' do
            get :show, params: { id: application_id }

            expect(application.navigation_stack).to eq(navigation_stack)
          end
        end
      end
    end

    context 'for update endpoints' do
      context 'when the stack is empty' do
        let(:navigation_stack) { [] }

        it 'adds the page to the stack' do
          put :update, params: { id: application_id }

          expect(application.navigation_stack).to eq([dummy_step_path])
        end
      end

      context 'when the current page is on the stack' do
        let(:navigation_stack) { ['/foo', '/bar', dummy_step_path, '/baz'] }

        it 'rewinds the stack to the appropriate point' do
          put :update, params: { id: application_id }

          expect(application.navigation_stack).to eq(['/foo', '/bar', dummy_step_path])
        end

        context 'but skip_stack is true' do
          before do
            expect(DummyStepImplementation).to receive(:skip_stack).and_return(true)
          end

          it 'does not modify stack' do
            put :update, params: { id: application_id }

            expect(application.navigation_stack).to eq(['/foo', '/bar', dummy_step_path, '/baz'])
          end
        end
      end

      context 'when the current page is not on the stack' do
        let(:navigation_stack) { %w[/foo /bar /baz] }

        it 'adds it to the end of the stack' do
          put :update, params: { id: application_id }

          expect(application.navigation_stack).to eq(navigation_stack + [dummy_step_path])
        end

        context 'but skip_stack is true' do
          before do
            expect(DummyStepImplementation).to receive(:skip_stack).and_return(true)
          end

          it 'does not modify stack' do
            put :update, params: { id: application_id }

            expect(application.navigation_stack).to eq(navigation_stack)
          end
        end
      end
    end
  end

  describe '#update_and_advance' do
    context 'when saving as a draft' do
      let(:params) { { id: application.id, test_model: { first: 1, second: 2 }, commit_draft: '' } }

      it 'sets the paramters on the form' do
        expect(form_class).to receive(:new)
          .with({ 'application' => application,
                  'record' => application,
                  'first' => '1',
                  'second' => '2' })

        put :update, params:
      end

      context 'additional/missing params are passed in' do
        let(:params) { { id: application.id, test_model: { first: 1, third: 3 }, commit_draft: '' } }

        it 'ignore additional and skips missing params' do
          expect(form_class).to receive(:new)
            .with({ 'application' => application,
                    'record' => application,
                    'first' => '1' })

          put :update, params:
        end
      end

      it 'calls save! on the form' do
        expect(form).to receive(:save!)

        put :update, params:
      end

      context 'with no after_commit_redirect_path specified' do
        it 'redirects to the after_commit_path' do
          put(:update, params:)

          expect(response).to redirect_to(nsm_after_commit_path(id: application.id))
        end
      end

      context 'with an after_commit_redirect_path specified' do
        let(:options) do
          {
            as: :claim_type,
            after_commit_redirect_path: wherever_path(id: application.id)
          }
        end

        it 'redirects to the specified path' do
          put(:update, params:)

          expect(response).to redirect_to(wherever_path(id: application.id))
        end
      end
    end

    context 'when refreshing (with save)' do
      let(:form) { instance_double(Steps::BaseFormObject, application: application, record: record, save!: true) }
      let(:record) { application }
      let(:params) { { id: application.id, test_model: { first: 1, second: 2 }, save_and_refresh: '' } }

      it 'sets the paramters on the form' do
        expect(form_class).to receive(:new)
          .with({ 'application' => application,
                  'record' => application,
                  'first' => '1',
                  'second' => '2' })

        put :update, params:
      end

      context 'additional/missing params are passed in' do
        let(:params) { { id: application.id, test_model: { first: 1, third: 3 }, commit_draft: '' } }

        it 'ignore additional and skips missing params' do
          expect(form_class).to receive(:new)
            .with({ 'application' => application,
                    'record' => application,
                    'first' => '1' })

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

    context 'when reloading (without save)' do
      let(:form) { instance_double(Steps::BaseFormObject, application: application, record: record, valid?: true) }
      let(:record) { application }
      let(:params) { { id: application.id, test_model: { first: 1, second: 2 }, reload: true } }

      it 'sets the paramters on the form' do
        expect(form_class).to receive(:new)
          .with({ 'application' => application,
                  'record' => application,
                  'first' => '1',
                  'second' => '2' })

        put :update, params:
      end

      context 'additional/missing params are passed in' do
        let(:params) { { id: application.id, test_model: { first: 1, third: 3 }, reload: true } }

        it 'ignore additional and skips missing params' do
          expect(form_class).to receive(:new)
            .with({ 'application' => application,
                    'record' => application,
                    'first' => '1' })

          put :update, params:
        end
      end

      it 'calls the subclass implementation of reload' do
        put(:update, params:)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when saving the record' do
      let(:params) { { id: application.id, test_model: { first: 1, second: 2 } } }

      it 'sets the paramters on the form' do
        expect(form_class).to receive(:new)
          .with({ 'application' => application,
                  'record' => application,
                  'first' => '1',
                  'second' => '2' })

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
