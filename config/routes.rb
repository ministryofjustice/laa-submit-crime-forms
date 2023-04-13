Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "home#index"

  resource :errors, only: [] do
    get :application_not_found
    get :invalid_session
    get :unhandled
    get :unauthorized
    get :not_enrolled
    get :not_found
  end

  devise_for :providers,
             skip: [:all],
             controllers: {
               omniauth_callbacks: 'providers/omniauth_callbacks'
             }

  devise_scope :provider do
    get 'login', to: 'errors#unauthorized', as: :new_provider_session

    namespace :providers do
      delete 'logout', to: 'sessions#destroy', as: :logout
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

