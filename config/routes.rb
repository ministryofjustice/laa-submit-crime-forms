require 'sidekiq/web'

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://web.archive.org/web/20180709235757/https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username),
                                                Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_WEB_UI_USERNAME', nil))) &
      ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password),
                                                  Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_WEB_UI_PASSWORD', nil)))
  end
  mount Sidekiq::Web => '/sidekiq'

  extend RouteHelpers

  get :ping, to: 'healthcheck#ping'
  get :ready, to: 'healthcheck#ready'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root 'home#index'

  devise_for :providers,
             skip: [:all],
             controllers: {
               omniauth_callbacks: 'providers/omniauth_callbacks'
             }

  devise_scope :provider do
    if FeatureFlags.omniauth_test_mode.enabled?
      get 'login', to: 'home#dev_login', as: :new_provider_session
    else
      get 'login', to: 'errors#unauthorized', as: :new_provider_session
    end

    namespace :providers do
      delete 'logout', to: 'sessions#destroy', as: :logout
      get 'logout', to: 'sessions#destroy'
    end
  end

  namespace :about do
    resources :cookies, only: [:index, :create]
    get :update_cookies
    get :privacy
    get :contact
    get :accessibility
  end

  namespace :errors do
    resources :inactive_offices, only: [:index]
  end

  namespace :nsm, path: 'non-standard-magistrates' do
    resources :claims, except: [:edit, :show, :new, :update], as: :applications do
      collection do
        get :draft
        get :submitted
        get :reviewed, to: 'claims#index'
        get :search
      end
      member do
        get :delete
        get :confirm_delete, path: 'confirm-delete'
        constraints ->(_req) { !HostEnv.production? } do
          get :clone
        end
      end
    end

    constraints ->(_) { FeatureFlags.import_claims.enabled? } do
      resources :imports, only: %i[new create]
      get '/imports/errors', as: :import_errors
    end

    resources :offences, only: [:index], format: :js

    scope 'applications/:id' do
      # This is used as a generic redirect once a draft has been commited
      # The idea is that this can be custom to the implementation without
      # requiring an additional method to store the path.
      get '/steps/start_page', to: 'steps/start_page#show', as: 'after_commit'

      namespace :steps do
        edit_step :claim_type
        edit_step :office_area
        edit_step :court_area
        edit_step :case_transfer
        show_step :start_page
        edit_step :firm_details
        edit_step :contact_details
        edit_step :office_code
        edit_step :case_details
        constraints ->(_req) { FeatureFlags.youth_court_fee.enabled? } do
          edit_step :case_category
        end
        edit_step :case_disposal
        edit_step :hearing_details
        constraints ->(_req) { FeatureFlags.youth_court_fee.enabled? } do
          edit_step :case_outcome
        end
        crud_step :defendant_details, param: :defendant_id, except: [:destroy]
        edit_step :defendant_summary
        crud_step :defendant_delete, param: :defendant_id, except: [:destroy]
        edit_step :reason_for_claim
        edit_step :claim_details
        edit_step :letters_calls
        crud_step :work_item, param: :work_item_id, except: [:destroy]
        edit_step :work_items
        crud_step :work_item_delete, param: :work_item_id, except: [:destroy]
        edit_step :disbursement_add
        crud_step :disbursement_type, param: :disbursement_id, except: [:destroy] do
          member do
            get :duplicate
          end
        end
        crud_step :disbursement_cost, param: :disbursement_id, except: [:destroy]
        crud_step :disbursement_delete, param: :disbursement_id, except: [:destroy]
        edit_step :disbursements
        show_step :cost_summary
        edit_step :other_info
        upload_step :supporting_evidence do
          collection do
            get :download
          end
        end
        edit_step :equality
        constraints ->(_req) { FeatureFlags.youth_court_fee.enabled? } do
          edit_step :youth_court_claim_additional_fee
        end
        edit_step :equality_questions
        edit_step :solicitor_declaration
        edit_step :rfi_solicitor_declaration
        upload_step :further_information
        show_step :claim_confirmation
        show_step :check_answers
        show_step :view_claim do
          member do
            scope 'claimed_costs' do
              get 'work_items', to: 'view_claim#claimed_work_items', as: :claimed_costs_work_items
              get 'letters_and_calls', to: 'view_claim#claimed_letters_and_calls', as: :claimed_costs_letters_and_calls
              get 'disbursements', to: 'view_claim#claimed_disbursements', as: :claimed_costs_disbursements
              get 'additional_fees', to: 'view_claim#claimed_additional_fees', as: :claimed_costs_additional_fees
            end

            scope 'adjusted' do
              get 'work_items', to: 'view_claim#adjusted_work_items', as: :adjustments_work_items
              get 'letters_and_calls', to: 'view_claim#adjusted_letters_and_calls', as: :adjustments_letters_and_calls
              get 'disbursements', to: 'view_claim#adjusted_disbursements', as: :adjustments_disbursements
              get 'additional_fees', to: 'view_claim#adjusted_additional_fees', as: :adjustments_additional_fees
            end

            get ':item_type/:item_id', as: :item, to: 'view_claim#item',
                              constraints: { item_type: /(work_item|disbursement)/ }
            get :letters, to: 'view_claim#item', defaults: { item_type: 'letters' }
            get :calls, to: 'view_claim#item', defaults: { item_type: 'calls' }
            get :additional_fees, to: 'view_claim#item', defaults: { item_type: 'additional_fees' }
            get :download
            post :subscribe
            delete :unsubscribe
          end
        end
      end
    end
  end

  namespace :prior_authority, path: 'prior-authority' do
    resources :service_types, only: [:index], format: :js

    scope 'applications/:application_id' do
      namespace :steps do
        edit_step :prison_law
        edit_step :authority_value
        show_step :start_page
        edit_step :ufn
        edit_step :case_contact
        edit_step :office_code
        edit_step :client_detail
        edit_step :next_hearing
        edit_step :case_detail
        edit_step :hearing_detail
        edit_step :youth_court
        edit_step :psychiatric_liaison
        edit_step :primary_quote
        edit_step :service_cost
        show_step :primary_quote_summary
        edit_step :travel_detail
        edit_step :delete_travel
        edit_step :additional_costs
        resources :additional_cost_details, only: %i[new create edit update destroy] do
          member { get :confirm_delete }
        end
        edit_step :alternative_quotes
        resources :alternative_quote_details, only: %i[new create edit update destroy] do
          member { get :confirm_delete }
        end
        upload_step :reason_why
        upload_step :further_information
        edit_step :check_answers
        show_step :submission_confirmation
      end
    end

    resources :applications, only: %i[index show create destroy] do
      collection do
        get :drafts
        get :submitted
        get :reviewed, to: 'applications#index'
        get :search
      end
      member do
        get 'offboard'
        get :confirm_delete, path: 'confirm-delete'
        get :download
        constraints ->(_req) { !HostEnv.production? } do
          get :clone
        end
      end
    end
  end

  resources :downloads, only: :show

  get 'robots.txt', to: 'robots#index'

  post :app_store_webhook, to: 'sync#sync_individual'

  resource :errors, only: [] do
    get :application_not_found
    get :invalid_session
    get :unhandled
    get :unauthorized
    get :not_enrolled
    get :not_found
  end

  match '*path', to: 'errors#not_found', via: :all, constraints:
    ->(_request) { !Rails.application.config.consider_all_requests_local }
end
# rubocop:enable Metrics/BlockLength
