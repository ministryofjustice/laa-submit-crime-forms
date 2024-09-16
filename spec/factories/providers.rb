FactoryBot.define do
  factory :provider do
    auth_provider { 'saml' }
    uid { 'test-user' }
    office_codes { ['1A123B'] }
    email { 'provider@example.com' }
    settings { {} }

    trait :other do
      uid { SecureRandom.uuid }
    end
  end
end
