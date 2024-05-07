Rails.application.routes.draw do
  extend RouteHelpers

  mount LaaMultiStepForms::Engine => '/laa_multi_step_forms'

  put '/dummy_step/:id/after_commit', to: 'home#index', as: :nsm_after_commit
  get '/dummy_step/:id', to: 'dummy_step#show'
  put '/dummy_step/:id', to: 'dummy_step#update'
  get '/dummy_application/:id/wherever', to: 'start_page#show', as: :wherever

  root 'home#index'

  # Some of the views that are rendered in the tests expect these paths to exist
  get '/callback', to: 'home#index', as: :provider_saml_omniauth_authorize
  get '/applications', to: 'home#index', as: :nsm_applications

  scope 'applications/:id' do
    namespace :steps do
      edit_step :claim_type
      show_step :start_page
      show_step :stop_page do
        member do
          get :maybe
        end
      end
      crud_step :defendant, param: :defendant_id, except: [:destroy]
      crud_step :work_item, param: :work_item_id do
        member do
          get :duplicate
        end
      end
      upload_step :supporting_evidence
      upload_step :downloadable_entity do
        collection { get :download }
      end
    end
  end
end
