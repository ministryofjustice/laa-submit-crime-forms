require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://web.archive.org/web/20180709235757/https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_WEB_UI_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_WEB_UI_PASSWORD"]))
  end
  mount Sidekiq::Web => "/sidekiq"

  extend RouteHelpers

  get :ping, to: 'healthcheck#ping'

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
    resources :feedback, only: [:index, :create]
    resources :cookies, only: [:index, :create]
    get :update_cookies
    get :privacy
    get :contact
    get :accessibility
  end

  namespace :nsm, path: 'non-standard-magistrates' do
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
        upload_step :supporting_evidence do
          collection {
            get :download
          }
        end
        edit_step :equality
        edit_step :equality_questions
        edit_step :solicitor_declaration
        show_step :claim_confirmation
        show_step :check_answers
        show_step :view_claim
      end
    end
  end

  namespace :prior_authority, path: 'prior-authority' do
    scope 'applications/:id' do
      get '/steps/start_page', to: 'steps/start_page#show', as: 'after_commit'

      namespace :steps do
        edit_step :prison_law
        edit_step :authority_value
        show_step :start_page
        edit_step :ufn
        edit_step :case_contact
        edit_step :client_detail
        edit_step :primary_quote
        edit_step :next_hearing
        edit_step :case_detail
        edit_step :hearing_detail
        edit_step :youth_court
        edit_step :psychiatric_liaison
      end
    end

    resources :applications, only: %i[index show create destroy] do
      member do
        get 'offboard'
        get :confirm_delete, path: 'confirm-delete'
      end
    end

    root to: 'applications#index'
  end

  match '*path', to: 'laa_multi_step_forms/errors#not_found', via: :all, constraints:
    lambda { |_request| Rails.application.config.consider_all_requests_local }
end
