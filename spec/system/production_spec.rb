require 'system_helper'

def convert_path(path)
  path.gsub(%r{:[^/]+}) do |param|
    case param
    when ':item_type'
      'claimed_costs'
    when ':item_id'
      'work_items'
    when ':format'
      'json'
    else
      '1'
    end
  end
end

def should_skip_auth(controller)
  ignored_actions = ['verify_authenticity_token', 'authenticate_provider!']
  controller._process_action_callbacks
            .select { |callback| callback.kind == :before }
            .select { |callback| callback.filter.is_a?(Symbol) }
            .select { |callback| callback.instance_variable_get(:@if).blank? }
            .any? do |callback|
    name = callback.filter.to_s
    callback.instance_variable_get(:@negated) && ignored_actions.include?(name)
  end
end

def get_route_info(route)
  controller_name = "#{route.defaults[:controller]&.camelize}Controller"
  controller = controller_name.safe_constantize
  path = route.path.spec.to_s
  return unless controller && path.present? && controller < ApplicationController

  {
    path: convert_path(path),
    controller: controller,
    skips_auth: should_skip_auth(controller),
    raw_path: route.path.spec.to_s.gsub('(.:format)', ''),
    verb: route.verb.downcase.split('|'),
    action: route.defaults[:action],
  }
end

def get_routes(public)
  Rails.application.routes.routes
       .filter_map { |route| get_route_info(route) }
       .select { |route| route[:skips_auth] == public }
       .take(3)
end

RSpec.describe 'Route Authentication', type: :routing do
  let(:environment) { 'production' }

  before do
    allow(HostEnv).to receive(:env_name).and_return(environment)
    Rails.application.reload_routes!
    post provider_entra_id_omniauth_callback_path
  end

  routes do
    ActionDispatch::Routing::RouteSet.new_with_config(Rails.application.config)
  end

  get_routes(true).each do |route|
    route[:verb].each do |verb|
      describe "#{route[:controller]}##{route[:action]}" do
        it "allows #{verb.upcase} access to #{route[:raw_path]}" do
          expect(verb.to_sym => route[:path]).to be_routable
        end
      end
    end
  end

  get_routes(false).each do |route|
    route[:verb].each do |verb|
      describe "#{route[:controller]}##{route[:action]}" do
        it "requires authentication for #{verb.upcase} #{route[:raw_path]}" do
          expect(verb.to_sym => route[:path]).not_to be_routable
        end
      end
    end
  end

  describe 'DevAuth' do
    context 'in the production environment' do
      let(:environment) { 'production' }

      before do
        allow(FeatureFlags).to receive(:omniauth_test_mode)
          .and_return(double(:omniauth_test_mode, enabled?: false))
        Rails.application.reload_routes!
      end

      it 'routes /login to errors#unauthorized' do
        expect(Rails.application.routes.recognize_path('/login')).to eq(
          controller: 'errors',
          action: 'unauthorized'
        )
      end
    end

    context 'in the dev environment' do
      let(:environment) { 'development' }

      it 'routes /login to home#dev_login' do
        expect(Rails.application.routes.recognize_path('/login')).to eq(
          controller: 'home',
          action: 'dev_login'
        )
      end
    end
  end

  describe 'when we try and access a missing controller' do
    let(:environment) { 'production' }

    before do
      Rails.application.routes.draw do
        get '/', to: 'missing_controller#index'
      end
    end

    after do
      Rails.application.reload_routes!
    end

    it 'raises error when controller is missing' do
      expect do
        Rails.application.routes.recognize_path('/', method: :get)
      end.to raise_error(ActionController::RoutingError, /references missing controller: MissingControllerController/)
    end
  end
end
