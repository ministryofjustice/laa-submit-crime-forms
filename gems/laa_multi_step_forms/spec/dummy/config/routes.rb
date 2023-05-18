Rails.application.routes.draw do
  mount LaaMultiStepForms::Engine => '/laa_multi_step_forms'

  put '/dummy_step/:id/after_commit', to: 'home#index', as: :after_commit
  get '/dummy_step/:id', to: 'dummy_step#show'
  put '/dummy_step/:id', to: 'dummy_step#update'

  root 'home#index'
end
