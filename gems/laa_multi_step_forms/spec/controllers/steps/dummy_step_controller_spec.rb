require 'rails_helper'

class DummyStepController < Steps::BaseStepController
  def show
    head(:ok)
  end

  private

  def current_application
    DummyStepImplementation.current_application
  end

  def authenticate_provider!
    true
  end
end

# used so that we can easily stub this method into the controller
class DummyStepImplementation
  def self.current_application; end
end

RSpec.describe DummyStepController, type: :controller do
  before do
    Rails.application.routes.append do
      get '/dummy_step/:id', to: 'dummy_step#show'
      get '/dummy_step/:id/edit', to: 'dummy_step#edit'
      put '/dummy_step/:id', to: 'dummy_step#update'
    end
    Rails.application.reload_routes!
  end

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
end
