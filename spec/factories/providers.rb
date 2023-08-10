FactoryBot.define do
  factory :provider do
    id { SecureRandom.uuid }

    auth_provider { 'saml' }
    uid { 'test-user' }
    office_codes { ['AAA'] }
    email { 'provider@example.com' }
  end
end
