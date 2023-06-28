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
    # This is used as a generic redirect once a draft has been commited
    # The idea is that this can be custom to the implementation without
    # requiring an additional method to store the path.
    get '/steps/start_page', to: 'steps/start_page#show', as: 'after_commit'

    namespace :steps do
      edit_step :claim_type
      show_step :start_page
      edit_step :firm_details
      edit_step :case_details
      edit_step :case_disposal
      edit_step :hearing_details
      edit_step :defendant_details
      edit_step :defendant_summary
      edit_step :defendant_delete
      edit_step :reason_for_claim
      edit_step :claim_details
      edit_step :letters_calls
      edit_step :work_item
      edit_step :work_items
      edit_step :work_item_delete
      crud_step :disbursement_type, param: :disbursement_id, except: [:destroy]
      crud_step :disbursement_cost, param: :disbursement_id, except: [:destroy]
      show_step :cost_summary
      edit_step :other_info

    end
  end
end
