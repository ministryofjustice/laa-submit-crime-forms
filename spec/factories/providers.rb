FactoryBot.define do
  factory :provider do
    id { SecureRandom.uuid }

    auth_provider { 'saml' }
    uid { 'test-user' }
    office_codes { ['1A123B'] }
    email { 'provider@example.com' }
    settings { { selected_office_code: '1A123B' } }
  end
end
