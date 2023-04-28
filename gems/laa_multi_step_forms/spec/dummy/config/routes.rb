Rails.application.routes.draw do
  mount LaaMultiStepForms::Engine => '/laa_multi_step_forms'

  root 'home#index'
end
