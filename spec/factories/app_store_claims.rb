factory :app_store_claim, class: AppStore::V1::Nsm::Claim, parent: :claim do
  laa_reference { 'LAA-ABC123' }
end
