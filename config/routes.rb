Rails.application.routes.draw do
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
    get 'login', to: 'errors#unauthorized', as: :new_provider_session

    namespace :providers do
      delete 'logout', to: 'sessions#destroy', as: :logout
      get 'logout', to: 'sessions#destroy'
    end
  end

  resources :claims do
    member do
      get :delete
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
end

