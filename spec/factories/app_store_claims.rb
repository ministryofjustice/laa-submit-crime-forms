FactoryBot.define do
  factory :app_store_claim, class: AppStore::V1::Nsm::Claim, parent: :claim do
    laa_reference { 'LAA-ABC123' }

    initialize_with { new(app_store_record: attributes) }
  end
end
