Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
    root "main#index"

    get 'main/index'

    resources :claims do
      member do
        get :delete
      end
    end

    resources :provider_offices do
      member do
        get :delete
      end
    end

    resources :provider_solicitors do
      member do
        get :delete
      end
    end

    # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

    # Defines the root path route ("/")
  end

