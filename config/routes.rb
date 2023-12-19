require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq"

  extend RouteHelpers

  get :ping, to: 'healthcheck#ping'

  # mount this at the route
  mount LaaMultiStepForms::Engine, at: '/'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "home#index"

  devise_for :users,
             skip: [:all],
             controllers: {
               omniauth_callbacks: 'users/omniauth_callbacks'
             }

  devise_scope :user do
    get 'login', to: 'laa_multi_step_forms/errors#unauthorized', as: :new_user_session

    namespace :users do
      delete 'logout', to: 'sessions#destroy', as: :logout
      get 'logout', to: 'sessions#destroy'
    end

    unauthenticated :user do
      root 'users/sessions#new', as: :unauthenticated_root
    end

    authenticated :user do
      get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
    end
  end


  namespace :about do
    resources :feedback, only: [:index, :create]
    resources :cookies, only: [:index, :create]
    get :update_cookies
    get :privacy
    get :contact
    get :accessibility
  end

  resources :claims, except: [:edit, :show, :new, :update], as: :applications do
    member do
      get :delete
    end
  end

  resources :offences, only: [:index], format: :js

  namespace :steps do
    namespace :office do
      edit_step :confirm
      edit_step :select
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
      crud_step :defendant_details, param: :defendant_id, except: [:destroy]
      edit_step :defendant_summary
      crud_step :defendant_delete, param: :defendant_id, except: [:destroy]
      edit_step :reason_for_claim
      edit_step :claim_details
      edit_step :letters_calls
      crud_step :work_item, param: :work_item_id, except: [:destroy] do
        member do
          get :duplicate
        end
      end
      edit_step :work_items
      crud_step :work_item_delete, param: :work_item_id, except: [:destroy]
      edit_step :disbursement_add
      crud_step :disbursement_type, param: :disbursement_id, except: [:destroy]
      crud_step :disbursement_cost, param: :disbursement_id, except: [:destroy]
      crud_step :disbursement_delete, param: :disbursement_id, except: [:destroy]
      edit_step :disbursements
      show_step :cost_summary
      edit_step :other_info
      upload_step :supporting_evidence
      edit_step :equality
      edit_step :equality_questions
      edit_step :solicitor_declaration
      show_step :claim_confirmation
      show_step :check_answers
      show_step :view_claim
    end
  end

  namespace :assess do
    root "landing#index"

    resources :landing, only: [:index]
    resources :claims, only: [:new, :index] do
      resource :claim_details, only: [:show]
      resource :adjustments, only: [:show]
      namespace :letters_and_calls do
        resource :uplift, only: [:edit, :update], path_names: { edit: '' }
      end
      namespace :work_items do
        resource :uplift, only: [:edit, :update], path_names: { edit: '' }
      end
      resources :work_items, only: [:index, :show, :edit, :update]
      resources :letters_and_calls, only: [:index, :show, :edit, :update], constraints: { id: /(letters|calls)/ }
      resources :disbursements, only: [:index, :show, :edit, :update]
      resource :supporting_evidences, only: [:show]
      resource :history, only: [:show, :create]
      resource :change_risk, only: [:edit, :update], path_names: { edit: '' }
      resource :make_decision, only: [:edit, :update], path_names: { edit: '' }
      resource :send_back, only: [:edit, :update], path_names: { edit: '' }
      resource :unassignment, only: [:edit, :update], path_names: { edit: '' }
    end

    get 'claims/:claim', to: redirect('claims/%{claim}/claim_details')

    resources :your_claims, only: [:index]
    resources :assessed_claims, only: [:index]

    namespace :about do
      resources :feedback, only: [:index, :create]
      resources :cookies, only: [:index, :create]
      get :update_cookies, to: '/assess/about/cookies#update_cookies'
      get :privacy
      get :accessibility
    end
  end

  match '*path', to: 'laa_multi_step_forms/errors#not_found', via: :all, constraints:
    lambda { |_request| Rails.application.config.consider_all_requests_local }
end
