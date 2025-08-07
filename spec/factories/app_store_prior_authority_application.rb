FactoryBot.define do
  factory :app_store_prior_authority_application,
          class: AppStore::V1::PriorAuthority::Application,
          parent: :prior_authority_application do
    laa_reference { 'LAA-ABC123' }
  end
end
