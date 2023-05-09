require 'rails_helper'

class DummyStepController < Steps::BaseStepController
  def show
    DummyStepImplementation.show()
    head(:ok)
  end

  def current_application
    DummyStepImplementation.current_application
  end
end

class DummyStepImplementation
  def self.show
  end

  def self.current_application
  end
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
    let!(:application) { double(:claim, id: SecureRandom.uuid, save: true, 'navigation_stack=': true, navigation_stack: ) }
    let(:dummy_step_path) { "/dummy_step/#{application.id}" }

    before do
      allow(DummyStepImplementation).to receive(:current_application).and_return(application)

      get :show, params: { id: application }
      application.reload
    end

    context 'when the stack is empty' do
      let(:navigation_stack) { [] }

      it 'adds the page to the stack' do
        expect(application.navigation_stac=).to have_received([dummy_step_path])
      end
    end

    context 'when the current page is on the stack' do
      let(:navigation_stack) { ['/foo', '/bar', dummy_step_path, '/baz'] }

      it 'rewinds the stack to the appropriate point' do
        expect(application.navigation_stack).to eq(['/foo', '/bar', dummy_step_path])
      end
    end

    context 'when the current page is not on the stack' do
      let(:navigation_stack) { %w[/foo /bar /baz] }

      it 'adds it to the end of the stack' do
        expect(application.navigation_stack).to eq(navigation_stack + [dummy_step_path])
      end
    end
  end
end
