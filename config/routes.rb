module RouteHelpers
  def edit_step(name, opts = {}, &block)
  resource name,
           only: opts.fetch(:only, [:edit, :update]),
           controller: name,
           path_names: { edit: '' } do; block.call if block_given?; end
  end

  def crud_step(name, opts = {})
    edit_step name, only: [] do
      resources only: [:edit, :update, :destroy],
                except: opts.fetch(:except, []),
                controller: name, param: opts.fetch(:param),
                path_names: { edit: '' } do
        get :confirm_destroy, on: :member if parent_resource.actions.include?(:destroy)
      end
    end
  end

  def show_step(name)
    resource name, only: [:show], controller: name
  end
end

Rails.application.routes.draw do
  extend RouteHelpers
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # mount this at the route
  mount LaaMultiStepForms::Engine, at: '/'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "home#index"

  devise_for :providers,
             skip: [:all],
             controllers: {
               omniauth_callbacks: 'providers/omniauth_callbacks'
             }

  devise_scope :provider do
    get 'login', to: 'laa_multi_step_forms/errors#unauthorized', as: :new_provider_session

    namespace :providers do
      delete 'logout', to: 'sessions#destroy', as: :logout
      get 'logout', to: 'sessions#destroy'
    end
  end

  namespace :about do
    get :privacy
    get :contact
    get :feedback
    get :accessibility
  end

  resources :claims, except: [:edit, :show, :new, :update], as: :applications do
    member do
      get :delete
    end
  end

  scope 'applications/:id' do
    get '/steps/start_page', to: 'steps/start_page#show', as: 'commit_draft'
    get '/steps/start_page', to: 'steps/start_page#show', as: 'edit_application'
    namespace :steps do
      edit_step :claim_type
      show_step :start_page
      edit_step :firm_details
    end
  end
end
